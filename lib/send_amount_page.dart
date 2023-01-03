import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:msufcu_flutter_project/msufcu_color_scheme.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:msufcu_flutter_project/send_money.dart';
import 'sql/update.dart';
import 'widgets/dialog_box.dart';
import 'widgets/user_identifier.dart';
import 'widgets/interactive_button.dart';
import 'Classes/transactionHistory.dart';
import 'move_money.dart';
import 'objects/user_info.dart';
import 'sql/insertion.dart';

final now = DateTime.now();

/// Controller for the description TextField
final TextEditingController descriptionController = TextEditingController();

/// Controller for the monetary amount TextFormField
final TextEditingController monetaryAmountController = TextEditingController();

/// Formatter to add $ and two decimals to currency amounts
/// https://pub.dev/packages/currency_text_input_formatter
final CurrencyTextInputFormatter monetaryAmount =
    CurrencyTextInputFormatter(decimalDigits: 2, symbol: "\$");

/// Creates a transaction and adds it to the database if the
/// amount of money being sent or requested is above $0.00
void createTransaction(BuildContext context, UserInfo destUser,
    UserInfo sourceUser, bool flowing, bool fromScan) async {
  if (monetaryAmount.getUnformattedValue().toDouble() == 0) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const CustomDialogBox(
              title: "Invalid Amount",
              content:
                  "The amount you entered is not valid. Please enter a valid amount and try again.",
              button: "Okay");
        });
  } else {
    DateTime currTime = DateTime.now();
    String currTimeSinceEpoch = currTime.millisecondsSinceEpoch.toString();

    transactionHistory newTransaction = transactionHistory(
      monetaryAmount.getUnformattedValue().toDouble(),
      destUser.m_full_name,
      destUser.m_username,
      descriptionController.text,
      0,
      flowing,
      currTime,
    );
    Insert insert = Insert();
    List<String> payment = [
      sourceUser.m_id,
      destUser.m_id,
      newTransaction.amount.toString(),
      DateFormat('yyyy-MM-dd HH:mm:ss').format(newTransaction.time),
      newTransaction.description,
      newTransaction.flowing ? "0" : "1",
      newTransaction.status.toString()
    ];
    insert.insertInDatabase(payment, 'm2m_payment', false);

    // Insert if destUser not connected
    Set<String> connectedUsers = getConnectedMemberIds();
    if (!connectedUsers.contains(destUser.m_id)) {
      List<String> sourceDest = [
        sourceUser.m_id,
        destUser.m_id,
        "0",
        currTimeSinceEpoch
      ];

      List<String> destSource = [
        destUser.m_id,
        sourceUser.m_id,
        "0",
        currTimeSinceEpoch
      ];

      insert.insertInDatabase(sourceDest, 'contact', true);
      insert.insertInDatabase(destSource, 'contact', true);
    }
    // Otherwise, update last_connected time
    else {
      Update update = Update();

      await update.singleUpdateInDatabase(
          'last_contacted',
          currTimeSinceEpoch,
          'contact',
          "id_user = '${sourceUser.m_id}' AND connected_user = '${destUser.m_id}'");

      await update.singleUpdateInDatabase(
          'last_contacted',
          currTimeSinceEpoch,
          'contact',
          "id_user = '${destUser.m_id}' AND connected_user = '${sourceUser.m_id}'");
    }

    // Updates the current displayed users
    await getConnectedUsers(sourceUser);
    history.add(newTransaction);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    if (fromScan) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
    descriptionController.clear();
    getSearchingUsersNotifier().value = false;
    getSearchBarController().clear();
  }
}

/// Column containing two interactive buttons for sending
/// and requesting money from other users
class TransactionButtons extends StatelessWidget {
  const TransactionButtons(
      {super.key,
      required this.destUser,
      required this.sourceUser,
      required this.fromScan});

  final UserInfo destUser;
  final UserInfo sourceUser;
  final bool fromScan;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            InteractiveButton(
                title: "Send",
                width: 300,
                onPressed: () => createTransaction(
                    context, destUser, sourceUser, false, fromScan)),
            InteractiveButton(
                title: "Request",
                width: 300,
                onPressed: () => createTransaction(
                    context, destUser, sourceUser, true, fromScan))
          ],
        ));
  }
}

/// Creates a field to format entered amounts
/// of money to send and recieve
class MonetaryAmountField extends StatefulWidget {
  const MonetaryAmountField({super.key});

  @override
  State<MonetaryAmountField> createState() => _MonetaryAmountFieldState();
}

class _MonetaryAmountFieldState extends State<MonetaryAmountField> {
  // Input formatter that formats the text to currency amounts

  @override
  Widget build(BuildContext context) {
    monetaryAmountController.text = monetaryAmount.format("0");
    return TextFormField(
        controller: monetaryAmountController,
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(10),
          monetaryAmount
        ],
        keyboardType: TextInputType.number,
        style: const TextStyle(color: msufcuMediumGrey, fontSize: 35),
        textAlign: TextAlign.end,
        textAlignVertical: TextAlignVertical.bottom,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(5)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(5))));
  }

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    monetaryAmountController.addListener(setEmptyValue);
    monetaryAmountController.addListener(setCursorAtEnd);
  }

  /// Only allow monetary input from the right side of the TextField
  void setCursorAtEnd() {
    if (monetaryAmountController.selection !=
        TextSelection.fromPosition(TextPosition(
            offset:
                monetaryAmount.format(monetaryAmountController.text).length))) {
      monetaryAmountController.selection = TextSelection.fromPosition(
          TextPosition(
              offset:
                  monetaryAmount.format(monetaryAmountController.text).length));
    }
  }

  /// Set the TextField value to $0.00 if it is empty
  void setEmptyValue() {
    if (monetaryAmountController.text.isEmpty) {
      monetaryAmountController.value = TextEditingValue(
          text: monetaryAmount.format("0"),
          selection: TextSelection.fromPosition(
              TextPosition(offset: monetaryAmount.format("0").length)));
    }
  }
}

/// Container with TextField that users input an amount
/// of money into
class EnterAmount extends StatelessWidget {
  const EnterAmount({super.key});

  @override
  Widget build(BuildContext context) {
    return const FractionallySizedBox(
        widthFactor: 0.6,
        child: SizedBox(height: 100, child: MonetaryAmountField()));
  }
}

/// Container with TextField that users can input a
/// short description to the reciever into
class EnterDescription extends StatelessWidget {
  const EnterDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 0.9,
        child: SizedBox(
            height: 250,
            child: TextField(
                textInputAction: TextInputAction.done,
                maxLength: 250,
                maxLines: null,
                minLines: 9,
                controller: descriptionController,
                style: const TextStyle(color: msufcuMediumGrey, fontSize: 20),
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                    hintText: "Description...",
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 2),
                        borderRadius: BorderRadius.circular(5)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 2),
                        borderRadius: BorderRadius.circular(5))))));
  }
}

/// Builds the layout for the page containing all
/// other sections to send money to a user
class SendAmountPage extends StatelessWidget {
  const SendAmountPage(
      {super.key,
      required this.destUser,
      required this.sourceUser,
      required this.fromScan});

  final UserInfo destUser;
  final UserInfo sourceUser;
  final bool fromScan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => {
                Navigator.of(context).pop(),
                descriptionController.clear(),
              },
            ),
            title: const Text("Send/Request Funds"),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black),
        resizeToAvoidBottomInset: false,
        body: Center(
            child: SingleChildScrollView(
                physics: const RangeMaintainingScrollPhysics(),
                child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        UserIdentifier(
                          user: destUser,
                          bottomPadding: 10,
                        ),
                        const EnterAmount(),
                        const EnterDescription(),
                        TransactionButtons(
                            destUser: destUser,
                            sourceUser: sourceUser,
                            fromScan: fromScan),
                      ],
                    ))));
  }
}
