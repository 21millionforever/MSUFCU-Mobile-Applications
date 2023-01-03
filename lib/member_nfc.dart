// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'objects/user_info.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:msufcu_flutter_project/widgets/interactive_button.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'send_amount_page.dart';

ValueNotifier<dynamic> result = ValueNotifier(null);
double anim_size = 0;

// Example code from https://pub.dev/packages/nfc_manager/example
class NFCPage extends StatefulWidget {
  const NFCPage({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;

  // Getter funciton that return logged in user
  UserInfo getLoggedInUser() {
    return loggedInUser;
  }

  @override
  State<NFCPage> createState() => NFCPageState();
}

class NFCPageState extends State<NFCPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => {
                setState(() {
                  anim_size = 0;
                }),
                NfcManager.instance.stopSession(),
                Navigator.of(context).pop()
              },
            ),
            title: const Text('MemberToMember™')),
        body: SafeArea(
          child: Column(children: [
            const Text("\n\n\n"), // padding
            const Text(
              "Tap button to begin, then hold phone up to a valid NFC tag to scan it...\n",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            InteractiveButton(
              title: "Scan for NFC",
              width: 200,
              onPressed: () => {
                setState(() {
                  anim_size = 40;
                }),
                _tagRead(context)
              },
            ),
            const Text("\n"),
            LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.black,
              size: anim_size,
            ),
          ]),
        ),
      ),
    );
  }

  // Read user info as ndef payload from an external nfc tag
  void _tagRead(context) {
    // Start an nfc session
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      NfcManager.instance.stopSession();

      // Extract and parse payload as text
      String payload = String.fromCharCodes(
          result.value["ndef"]["cachedMessage"]["records"][0]["payload"]);
      Map<String, String?> row = {};
      List<String> payloadList = payload.split(", ");
      row["MemberID"] = payloadList[0].substring(9);
      row["Username"] = payloadList[1].substring(10);
      row["Password"] = payloadList[2].substring(10);
      row["full_name"] = payloadList[3].substring(11);
      row["Email"] = payloadList[4].substring(7);
      row["QR_Code"] = payloadList[5].substring(4);
      row["Phone_Number"] = payloadList[6].substring(13);

      // Recreate the user from the parsed data and redirect to the send amount page
      UserInfo destUser = UserInfo(row);

      setState(() {
        anim_size = 0;
      });

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SendAmountPage(
          destUser: destUser,
          sourceUser: widget.loggedInUser,
          fromScan: true,
        );
      }));
    });
  }

  // // Write logged in usesrs info as text to an external nfc tag using ndef
  // void _ndefWrite() {
  //   // Start nfc session
  //   NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
  //     var ndef = Ndef.from(tag);

  //     // Check if tag supports ndef
  //     if (ndef == null || !ndef.isWritable) {
  //       result.value = 'Tag is not ndef writable';
  //       NfcManager.instance.stopSession(errorMessage: result.value);
  //       return;
  //     }

  //     // Create ndef message and attempt to write to external tag
  //     NdefMessage message = NdefMessage([NdefRecord.createText(loggedInUser.toString())]);
  //     try {
  //       await ndef.write(message);
  //       result.value = 'Success to "Ndef Write"';
  //       NfcManager.instance.stopSession();
  //     } catch (e) {
  //       result.value = e;
  //       NfcManager.instance.stopSession(errorMessage: result.value.toString());
  //       return;
  //     }
  //   });
  // }
}
