import 'package:flutter/material.dart';

class PaymentSelector extends StatefulWidget {
  const PaymentSelector({super.key});

  @override
  State<PaymentSelector> createState() => _PaymentSelectorState();
}

class _PaymentSelectorState extends State<PaymentSelector> {
  int selectedIndex = 0;

  final List<String> options = ['SEND', 'RECEIVE', 'HISTORY'];
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      height: 0.15 * height,
      color: Colors.white60,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (BuildContext contenxt, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.11,
              vertical: height * 0.05,
            ),
            child: Text(options[index]),
          );
        },
      ),
    );
  }
}
