// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msufcu_flutter_project/Classes/transactionHistory.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:msufcu_flutter_project/objects/user_info.dart';
import 'sql/query.dart';

// Value for value identifier
double value = 10;

// Value notifier for the transactions that are displayed
ValueNotifier<List<transactionHistory>> displayedTransactions =
    ValueNotifier([]);

// Formatting for the money amount in the transaction
final CurrencyTextInputFormatter money_amount =
    CurrencyTextInputFormatter(decimalDigits: 2, symbol: "\$");

// State widget for the page
class TransactionHistory extends StatefulWidget {
  final UserInfo loggedInUser;
  const TransactionHistory({super.key, required this.loggedInUser});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  late Future<List<transactionHistory>> displayedHistory;
  @override
  // Initializes the displayed history from database.
  void initState() {
    super.initState();
    displayedHistory = getTransactionHistory(widget.loggedInUser);
  }

  // Called when refreshing the page, pull from database
  Future<void> _refreshTransactions(BuildContext context) async {
    getTransactionHistory(widget.loggedInUser);
  }

  // Builds the transaction history page
  // ignore: annotate_overrides
  Widget build(BuildContext context) {
    return RefreshIndicator(
        // When user refreshes page, calls the refresh functions
        onRefresh: () async {
          await _refreshTransactions(context);
        },
        // Builder for the list of transactions
        child: FutureBuilder(
            future: displayedHistory,
            builder: (BuildContext context,
                AsyncSnapshot<List<transactionHistory>> snapshot) {
              // Check if data was obtained from database call
              if (!snapshot.hasData) {
                // Display gray container if not
                return Container(
                    color: const Color.fromARGB(149, 82, 82, 82),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width);
              } else {
                displayedTransactions.value =
                    (snapshot.data as List<transactionHistory>).toList();
                return ValueListenableBuilder(
                    builder: (BuildContext context,
                        List<transactionHistory> value, Widget? child) {
                      return ListView.builder(
                        itemCount: displayedTransactions.value.length,
                        itemBuilder: (BuildContext context, int index) {
                          // Tapping on transaciton will take you to transaction details page
                          return GestureDetector(
                            onTap: (() => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TransactionDetail(
                                          history: displayedTransactions
                                              .value[index],
                                        )))),
                            child: Card(
                                color: Colors.white,
                                child: ListTile(
                                  // Formatting for how the details are displayed on the card
                                  title: displayedTransactions
                                              .value[index].flowing ==
                                          true
                                      ? Text(
                                          "From: ${displayedTransactions.value[index].fullName}")
                                      : Text(
                                          "To: ${displayedTransactions.value[index].fullName}"),
                                  subtitle: Text(
                                    "@${displayedTransactions.value[index].username}, ${DateFormat('yMd').format(displayedTransactions.value[index].time)}",
                                  ),
                                  leading: Icon(
                                    displayedTransactions
                                                .value[index].flowing ==
                                            true
                                        ? Icons.arrow_forward_rounded
                                        : Icons.arrow_back_rounded,
                                    color: displayedTransactions
                                                .value[index].flowing ==
                                            true
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  trailing: displayedTransactions
                                              .value[index].status ==
                                          0
                                      ? const Text("Pending...",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic))
                                      : Text(
                                          "\$${displayedTransactions.value[index].amount.toStringAsFixed(2)}",
                                          style: TextStyle(
                                              color: displayedTransactions
                                                          .value[index]
                                                          .flowing ==
                                                      true
                                                  ? Colors.green
                                                  : Colors.red),
                                        ),
                                )),
                          );
                        },
                      );
                    },
                    valueListenable: displayedTransactions);
              }
            }));
  }
}

/// Transaction details page
/// View that contains a more detailed look at the transaction
class TransactionDetail extends StatelessWidget {
  final transactionHistory history;
  const TransactionDetail({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Details"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
                child: Text(
              history.fullName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
          ),
          Text("@${history.username}", style: const TextStyle(fontSize: 15)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("\"${history.description}\"",
                style: const TextStyle(fontSize: 15)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "\$${history.amount}",
                  style: TextStyle(
                      color:
                          history.flowing == true ? Colors.green : Colors.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(DateFormat('yMd').format(history.time)),
              )
            ],
          )
        ],
      ),
    );
  }
}

/// Gets the transaction history by calling the database
/// Returns a list, sorted by date, of transaction history objects representing the data
///
Future<List<transactionHistory>> getTransactionHistory(
    UserInfo loggedInUser) async {
  Query query = Query();
  List<transactionHistory> transaction_history = await query.m2mQuery(
      "payment_ID, amount, T.full_name, T.Username, description, status, flowing, date",
      "user_info as F, user_info as T, m2m_payment",
      true,
      "m2m_payment.fromMember = F.MemberID and m2m_payment.toMember = T.MemberID and m2m_payment.fromMember = ${loggedInUser.m_id}");

  List<transactionHistory> transaction_history2 = await query.m2mQuery(
      "payment_ID, amount, F.full_name, F.Username, description, status, flowing, date",
      "user_info as F, user_info as T, m2m_payment",
      true,
      "m2m_payment.fromMember = F.MemberID and m2m_payment.toMember = T.MemberID and m2m_payment.toMember = ${loggedInUser.m_id}");
  transaction_history.addAll(transaction_history2);
  // Sorting the list by date before returning it.
  transaction_history.sort(
    (a, b) {
      return b.time.compareTo(a.time);
    },
  );
  // Changing the value of the displayed transactions so it updates in the future builder
  displayedTransactions.value = transaction_history;
  return transaction_history;
}
