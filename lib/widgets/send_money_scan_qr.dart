import 'package:flutter/material.dart';

import '../member_qr_code.dart';
import '../objects/user_info.dart';

/// Builds the section that sends user to the QR Code page
class ScanQR extends StatefulWidget {
  const ScanQR({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return QRCodePage(loggedInUser: widget.loggedInUser);
              }))
            },
        child: SizedBox(
            width: (MediaQuery.of(context).size.width - (40 * 3)) / 3,
            height: 80,
            child: const Icon(size: 40, Icons.qr_code_2_outlined)));
  }
}
