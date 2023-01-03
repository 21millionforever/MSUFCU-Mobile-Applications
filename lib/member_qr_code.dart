import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/msufcu_color_scheme.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'Classes/pair.dart';
import 'objects/user_info.dart';
import 'scan_qr_code.dart';
import 'widgets/user_identifier.dart';
import 'widgets/interactive_button.dart';

/// Encryption Key to prevent MemberIds from being read as strings
/// by non-MSUFCU qr scanners
final encryptionKey =
    encrypt.Key.fromBase64("6n/SYYKKzhQnMcO+hVYjFIxnDWoxFbGZJ1H8r/iAjc0=");
final iv = encrypt.IV.fromBase64("kroPMhdJoeP33GWHW53v0g==");
final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey));

Pair<encrypt.Encrypter, encrypt.IV> getEncryptionData() {
  return Pair(encrypter, iv);
}

// Temporary Static QR code, hope to create individual
// QR codes here once connection to database is established
class QRCode extends StatelessWidget {
  const QRCode({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;

  @override
  Widget build(BuildContext context) {
    final encrypted =
        encrypter.encrypt("MSUFCU_QR:${loggedInUser.m_id}", iv: iv);
    return QrImage(
      data: encrypted.base64,
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}

/// Share QR Code as pdf to make it easier for businesses to print out
/// https://pub.dev/packages/share_plus
void shareQRCodePDF(BuildContext context, String qrPDFPath) {
  final box = context.findRenderObject() as RenderBox?;
  Share.shareXFiles([XFile(qrPDFPath)],
      text:
          "Here is my MSUFCU QR Code. Scan it within the MSUFCU App to start transferring money with me!",
      subject: "My MSUFCU QR Code!",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
}

/// Create a PDF from bytes of QR Code image and return the path of the PDF file.
/// PDF: https://pub.dev/packages/pdf
/// Path Provider: https://pub.dev/packages/path_provider
Future<String> createQRCodePDF(String qrImagePath) async {
  pw.Document pdf = pw.Document();

  pw.MemoryImage image = pw.MemoryImage(File(qrImagePath).readAsBytesSync());

  pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(image),
        );
      }));

  String qrPDFPath = qrImagePath.replaceAll(".png", ".pdf");

  await File(qrPDFPath).writeAsBytes(await pdf.save());

  return qrPDFPath;
}

/// Shares an image of the logged in users QR Code
/// https://pub.dev/packages/share_plus
void shareQRCodeImage(BuildContext context, String qrImagePath) {
  final box = context.findRenderObject() as RenderBox?;
  Share.shareXFiles([XFile(qrImagePath)],
      text:
          "Here is my MSUFCU QR Code. Scan it within the MSUFCU App to start transfering money with me!",
      subject: "My MSUFCU QR Code!",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
}

/// Captures the QR Code widget and the user's name and username
/// and creates a png from it. It then returns a string to the path of the file.
/// Widget to Image: https://pub.dev/packages/widgets_to_image
/// Path Provider: https://pub.dev/packages/path_provider
Future<String> captureQRCodeImage(
    WidgetsToImageController imageController) async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  String currTime = DateTime.now().millisecondsSinceEpoch.toString();

  Uint8List? bytes = await imageController.capture();
  await File('$tempPath/$currTime.png').writeAsBytes(bytes as Uint8List);

  return '$tempPath/$currTime.png';
}

/// Lays out the View QR Code tab
// ignore: must_be_immutable
class QRCodePageLayout extends StatelessWidget {
  QRCodePageLayout({super.key, required this.loggedInUser});

  WidgetsToImageController imageController = WidgetsToImageController();

  final UserInfo loggedInUser;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
            physics: const RangeMaintainingScrollPhysics(),
            child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WidgetsToImage(
                        controller: imageController,
                        // Column containing member's name and username
                        child: Column(children: [
                          SizedBox(
                              width: 200,
                              child: DecoratedBox(
                                  decoration:
                                      const BoxDecoration(color: Colors.white),
                                  child: UserIdentifier(
                                    user: loggedInUser,
                                    bottomPadding: 10,
                                  ))),

                          // Box containing QR code and MSUFCU's logo
                          SizedBox(
                              width: 200,
                              height: 250,
                              child: DecoratedBox(
                                  decoration:
                                      const BoxDecoration(color: Colors.white),
                                  child: Column(
                                    children: [
                                      QRCode(loggedInUser: loggedInUser),
                                      Expanded(
                                          child: Image.asset(
                                              'images/msufcu-logo.png'))
                                    ],
                                  )))
                        ])),

                    // Container with two buttons to share and print QR code respectively
                    Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Column(children: [
                              InteractiveButton(
                                  title: "Share",
                                  onPressed: (() {
                                    captureQRCodeImage(imageController)
                                        .then((value) {
                                      shareQRCodeImage(context, value);
                                    });
                                  })),
                              Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: InteractiveButton(
                                      title: "Print",
                                      onPressed: (() {
                                        captureQRCodeImage(imageController)
                                            .then((qrImagePath) {
                                          createQRCodePDF(qrImagePath).then(
                                            (qrPDFPath) {
                                              shareQRCodePDF(
                                                  context, qrPDFPath);
                                            },
                                          );
                                        });
                                      })))
                            ])))
                  ],
                ))));
  }
}

/// Builds the entire page for dealing with the QR code
class QRCodePage extends StatelessWidget {
  const QRCodePage({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
                title: const Text("MemberToMember\u2120"),
                centerTitle: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                bottom: const TabBar(
                    labelColor: msufcuForestGreen,
                    tabs: [Tab(text: "Scan Code"), Tab(text: "View Code")])),
            body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ScanQRCodeLayout(loggedInUser: loggedInUser),
                  QRCodePageLayout(loggedInUser: loggedInUser),
                ])));
  }
}
