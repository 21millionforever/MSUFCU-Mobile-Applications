import 'package:flutter/material.dart';

/// Creates a widget that displays an NFC Icon
class NFCIcon extends StatelessWidget {
  const NFCIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: SizedBox(width: 40, height: 40, child: Column(children: const [
      Icon(Icons.rss_feed_outlined),
      Expanded(child: Text("NFC", style: TextStyle(fontWeight: FontWeight.bold)))
    ])));
  }
}
