// ignore_for_file: file_names, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/Classes/transactionHistory.dart';
import 'package:msufcu_flutter_project/sql/deletion.dart';
import 'package:msufcu_flutter_project/transaction_history.dart';
import 'objects/user_info.dart';
import 'sql/query.dart';
import 'sql/update.dart';

ValueNotifier<List<transactionHistory>> receivedTransactions =
    ValueNotifier([]);

class RecievePage extends StatefulWidget {
  final UserInfo loggedInUser;
  const RecievePage({super.key, required this.loggedInUser});
  @override
  State<RecievePage> createState() => _RecievePageState();
}

class _RecievePageState extends State<RecievePage> {
  late Future<List<transactionHistory>> receivedTransactionsFuture;
  @override
  void initState() {
    super.initState();
    receivedTransactionsFuture = receiveTransactions(widget.loggedInUser);
  }

  Future<void> _refreshTransactions(BuildContext context) async {
    getTransactionHistory(widget.loggedInUser);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          await _refreshTransactions(context);
        },
        child: FutureBuilder(
            future: receivedTransactionsFuture,
            builder: (BuildContext context,
                AsyncSnapshot<List<transactionHistory>> snapshot) {
              if (!snapshot.hasData) {
                return Container();
              } else {
                receivedTransactions.value =
                    (snapshot.data as List<transactionHistory>).toList();
                return ValueListenableBuilder(
                    builder: (BuildContext context,
                        List<transactionHistory> value, Widget? child) {
                      return ListView.builder(
                        itemCount: receivedTransactions.value.length,
                        itemBuilder: (context, index) {
                          return Card(
                              child: ListTile(
                            title: receivedTransactions.value[index].flowing ==
                                    true
                                ? Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text:
                                            "${receivedTransactions.value[index].fullName} sent: "),
                                    TextSpan(
                                        text:
                                            "\$${receivedTransactions.value[index].amount.toStringAsFixed(2)}",
                                        style: TextStyle(
                                            color: receivedTransactions
                                                        .value[index].flowing ==
                                                    true
                                                ? Colors.green
                                                : Colors.red))
                                  ]))
                                : Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text:
                                            "${receivedTransactions.value[index].fullName} requests: "),
                                    TextSpan(
                                        text:
                                            "\$${receivedTransactions.value[index].amount.toStringAsFixed(2)}",
                                        style: TextStyle(
                                            color: receivedTransactions
                                                        .value[index].flowing ==
                                                    true
                                                ? Colors.green
                                                : Colors.red))
                                  ])),
                            subtitle: Text(
                              "@${receivedTransactions.value[index].username}: ${receivedTransactions.value[index].description}",
                            ),
                            trailing: Container(
                                width: 70,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: IconButton(
                                          onPressed: () async {
                                            await updateTransaction(
                                                receivedTransactions
                                                    .value[index]);
                                            receiveTransactions(
                                                widget.loggedInUser);
                                          },
                                          icon: const Icon(Icons.check_circle,
                                              color: Colors.green)),
                                    ),
                                    Expanded(
                                      child: IconButton(
                                          onPressed: () async {
                                            await deleteTransaction(
                                                receivedTransactions
                                                    .value[index]);
                                            receiveTransactions(
                                                widget.loggedInUser);
                                          },
                                          icon: const Icon(
                                            Icons.block,
                                            color: Colors.red,
                                          )),
                                    )
                                  ],
                                )),
                          ));
                        },
                      );
                    },
                    valueListenable: receivedTransactions);
              }
            }));
  }
}

Future<List<transactionHistory>> receiveTransactions(
    UserInfo loggedInUser) async {
  Query query = Query();
  // ignore: non_constant_identifier_names
  List<transactionHistory> transaction_history = await query.m2mQuery(
      "payment_ID, amount, F.full_name, F.Username, description, status, flowing, date",
      "user_info as F, user_info as T, m2m_payment",
      true,
      "m2m_payment.fromMember = F.MemberID and m2m_payment.toMember = T.MemberID and m2m_payment.status = 0 and m2m_payment.toMember = ${loggedInUser.m_id}");

  receivedTransactions.value = transaction_history;
  return transaction_history;
}

Future<void> updateTransaction(transactionHistory data) async {
  Update update = Update();
  await update.singleUpdateInDatabase(
      "status", "1", "m2m_payment", "payment_ID=${data.paymentID}");
}

Future<void> deleteTransaction(transactionHistory data) async {
  Deletion delete = Deletion();
  await delete.deleteInDatabase("m2m_payment", "payment_ID=${data.paymentID}");
}
