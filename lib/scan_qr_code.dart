import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:msufcu_flutter_project/widgets/dialog_box.dart';
import 'package:msufcu_flutter_project/msufcu_color_scheme.dart';
import 'Classes/pair.dart';
import 'objects/user_info.dart';
import 'send_amount_page.dart';
import 'sql/query.dart';
import 'member_qr_code.dart';
import 'package:scan/scan.dart';
import 'package:image_picker/image_picker.dart';
import 'package:torch_light/torch_light.dart';

/// Sends user back to Send Money page and displays a dialog box
/// showing a reason for why the scan failed
void displayDialogBox(CustomDialogBox dialogBox, BuildContext context) {
  Navigator.of(context).pop();
  showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return dialogBox;
      });
}

/// Search the database for the user's qr code
Future<UserInfo> getUserByQRCode(String? scannedCode) async {
  Query query = Query();

  List<UserInfo> queriedUsers = await query.userInfoQuery(
      "*", "user_info", true, "MemberID = '$scannedCode';");

  return queriedUsers[0];
}

/// Handle a QR code passed in by user
void handleQRCode(
    Barcode barcode, BuildContext context, UserInfo loggedInUser) {
  late UserInfo user;
  RegExp regExp =
      RegExp('^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?\$');
  if (regExp.hasMatch(barcode.rawValue as String)) {
    // Decrypt message
    Pair<Encrypter, IV> qrEncrypter = getEncryptionData();
    List<String> memberID = qrEncrypter.first
        .decrypt(Encrypted.fromBase64(barcode.rawValue as String),
            iv: qrEncrypter.second)
        .split(":");

    // If MSUFCU QR code, check if user is scanning own code
    if (memberID[0] == "MSUFCU_QR") {
      // If scanning own code, don't allow it
      if (memberID[1] == loggedInUser.m_id) {
        CustomDialogBox dialogBox = const CustomDialogBox(
            title: "Invalid Scanner Usage",
            content:
                "You have attempted to scan your own QR Code. Please try scanning again with another member's QR Code.",
            button: "Okay");
        displayDialogBox(dialogBox, context);
        // Otherwise, take user to QR Code owner's page
      } else {
        getUserByQRCode(memberID[1]).then((value) => user = value).whenComplete(
            () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SendAmountPage(
                    destUser: user,
                    sourceUser: loggedInUser,
                    fromScan: true,
                  );
                })));
      }
      // If not MSUFCU code, let user know it cannot be scanned
    } else {
      CustomDialogBox dialogBox = const CustomDialogBox(
          title: "Invalid QR Code",
          content:
              "The QR code you have scanned is not affiliated with MSUFCU.",
          button: "Okay");
      displayDialogBox(dialogBox, context);
    }
    // If not base64 encoded, it will never be an MSUFCU QR Code so notify user
  } else {
    CustomDialogBox dialogBox = const CustomDialogBox(
        title: "Invalid QR Code",
        content: "The QR code you have scanned is not affiliated with MSUFCU.",
        button: "Okay");
    displayDialogBox(dialogBox, context);
  }
}

// ignore: must_be_immutable
class QRFunctions extends StatefulWidget {
  QRFunctions({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;
  bool flashlightOn = false;

  @override
  State<QRFunctions> createState() => _QRFunctionsState();
}

class _QRFunctionsState extends State<QRFunctions> {
  /// Toggles the flashlight
  void toggleFlashlight() {
    setState(() {
      widget.flashlightOn = !widget.flashlightOn;
      widget.flashlightOn
          ? TorchLight.enableTorch()
          : TorchLight.disableTorch();
    });
  }

  /// Retrieves an image from an image gallery and checks if it is a QR Code.
  /// If it is a QR Code, handle it. Otherwise, let the user know a QR Code could
  /// not be detected in the image they selected.
  /// Image Picker: https://pub.dev/packages/image_picker
  /// Image QR Scanner: https://pub.dev/packages/scan
  void retrieveQRImageFromGallery(BuildContext context) {
    ImagePicker().pickImage(source: ImageSource.gallery).then(
      (qrImage) {
        if (qrImage != null) {
          Scan.parse(qrImage.path).then((qrCode) {
            if (qrCode != null) {
              handleQRCode(
                  Barcode(rawValue: qrCode), context, widget.loggedInUser);
            } else {
              CustomDialogBox dialogBox = const CustomDialogBox(
                  title: "Invalid QR Code",
                  content:
                      "A QR Code could not be detected in the image you selected",
                  button: "Okay");
              displayDialogBox(dialogBox, context);
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: FractionallySizedBox(
            widthFactor: 0.7,
            child: SizedBox(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                  IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => toggleFlashlight(),
                      isSelected: widget.flashlightOn,
                      iconSize: 30,
                      color: msufcuForestGreen,
                      icon: const Icon(Icons.flashlight_off),
                      selectedIcon: const Icon(Icons.flashlight_on)),
                  IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => retrieveQRImageFromGallery(context),
                      iconSize: 30,
                      color: msufcuForestGreen,
                      icon: const Icon(Icons.camera))
                ]))));
  }
}

// ignore: must_be_immutable
class QRScanner extends StatelessWidget {
  const QRScanner({super.key, required this.loggedInUser});
  final UserInfo loggedInUser;

  @override
  Widget build(BuildContext context) {
    bool shrinkCamera = MediaQuery.of(context).size.width < 340;
    return SizedBox(
        height: shrinkCamera
            ? (MediaQuery.of(context).size.height -
                    (kBottomNavigationBarHeight + kToolbarHeight)) *
                0.65
            : MediaQuery.of(context).size.height * 0.6,
        child: MobileScanner(
            allowDuplicates: false,
            controller: MobileScannerController(
                facing: CameraFacing.back),
            onDetect: (barcode, args) {
              handleQRCode(barcode, context, loggedInUser);
            }));
  }
}

class ScanQRCodeLayout extends StatelessWidget {
  const ScanQRCodeLayout({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          QRScanner(loggedInUser: loggedInUser),
          QRFunctions(loggedInUser: loggedInUser)
        ]);
  }
}
