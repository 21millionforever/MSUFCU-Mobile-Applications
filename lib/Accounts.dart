// ignore_for_file: file_names, non_constant_identifier_names, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/msufcu_color_scheme.dart';
import 'package:percent_indicator/percent_indicator.dart';
import './objects/user_info.dart';
import './sql/query.dart';
import './objects/transaction.dart';

class Accounts extends StatefulWidget {
  late final UserInfo _loggedInUser;
  late final Future<List<Transaction>> transactions;

  Accounts(UserInfo loggedInUser, {super.key}) {
    _loggedInUser = loggedInUser;
    transactions = _getUserTransactionsFromDataBase(loggedInUser.m_id);
  }

  Future<List<Transaction>> _getUserTransactionsFromDataBase(
      String memberId) async {
    Query query = Query();
    List<Transaction> data = await query.transactionQuery('*', 'transaction',
        true, "MemberID='${_loggedInUser.m_id}' order by Date, TransactionID");
    return data;
  }

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Accounts",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // Page body
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            // Account balance
            children: [
              FutureBuilder<Widget>(
                future: balance(context, widget.transactions),
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.hasData) {
                    return Container(child: snapshot.data);
                  } else if (snapshot.hasError) {
                    return balance_widget_while_loading(context, true);
                  } else {
                    return balance_widget_while_loading(context, false);
                  }
                },
              ),

              // Monthly income & expenses
              Container(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.9,
                margin: const EdgeInsets.only(top: 10),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Monthly income & expenses",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  // )
                ),
              ),

              FutureBuilder<Widget>(
                future: MonthlyIncomeAndExpenses(context, widget.transactions),
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.hasData) {
                    return Container(child: snapshot.data);
                  } else if (snapshot.hasError) {
                    return MonthlyIncomeAndExpensesError(context);
                  } else {
                    return MonthlyIncomeAndExpensesError(context);
                  }
                },
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(left: 15, top: 15),
                          child: const Text(
                            "Transactions",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                      FutureBuilder<Widget>(
                        future: Transaction_widgets_list(
                            context, widget.transactions),
                        builder: (BuildContext context,
                            AsyncSnapshot<Widget> snapshot) {
                          if (snapshot.hasData) {
                            return Container(child: snapshot.data);
                          } else if (snapshot.hasError) {
                            return Container(color: Colors.red);
                          } else {
                            return Container(color: Colors.blue);
                          }
                        },
                      ),
                    ],
                  ))
            ],
          )),
    );
  }
}

/// Display all the transactions
Future<Widget> Transaction_widgets_list(
    context, Future<List<Transaction>> transaction) async {
  List<Transaction> transaction_history = await transaction;
  List<String> signs_list = [];
  Map<String, Icon> icon_map = {
    '+': const Icon(
        IconData(0xe12c, fontFamily: 'MaterialIcons', matchTextDirection: true),
        color: msufcuBrightGreen),
    '-': const Icon(
        IconData(0xe128, fontFamily: 'MaterialIcons', matchTextDirection: true),
        color: Colors.red)
  };
  double previousBalance = 0.0;
  for (int i = 0; i < transaction_history.length; i++) {
    if (previousBalance == 0) {
      previousBalance = double.parse(transaction_history[i].m_balance);
      signs_list.add('+');
      continue;
    } else if (previousBalance >
        double.parse(transaction_history[i].m_balance)) {
      signs_list.add('-');
    } else {
      signs_list.add('+');
    }
    previousBalance = double.parse(transaction_history[i].m_balance);
  }

  return Expanded(
    child: ListView(
      children: <Widget>[
        for (int i = transaction_history.length - 1; i >= 0; i--) ...[
          ListTile(
            leading: icon_map[signs_list[i]],
            title: Text(transaction_history[i].m_merchant),
            subtitle: Text(transaction_history[i].m_date),
            trailing:
                Text("${signs_list[i]} \$${transaction_history[i].m_amount}"),
            dense: true,
          ),
        ],
      ],
    ),
  );
}

Map<String, String> convertDateToMap(String date) {
  Map<String, String> date_map = {'Year': '', 'Month': '', 'Day': ''};
  date_map['Year'] = date.substring(0, 4);
  date_map['Month'] = date.substring(5, 7);
  date_map['Day'] = date.substring(8, 10);
  return date_map;
}

Future<Widget> MonthlyIncomeAndExpenses(
    context, Future<List<Transaction>> transaction) async {
  List<Transaction> transaction_history = await transaction;
  double montly_income = 0;
  double montly_expenses = 0;
  final now = DateTime.now();
  double previous_balance = 0;

  for (int i = 0; i < transaction_history.length; i++) {
    Map<String, String> transaction_date_map =
        convertDateToMap(transaction_history[i].m_date);

    // Skip transactions that don't match the current year and month
    if (transaction_date_map['Year'] != now.year.toString() ||
        transaction_date_map['Month'].toString() != now.month.toString()) {
      previous_balance = double.parse(transaction_history[i].m_balance);
      continue;
    }

    // The first transaction within the month
    if (previous_balance == 0) {
      previous_balance = double.parse(transaction_history[i].m_balance);
    } else if (previous_balance >
        double.parse(transaction_history[i].m_balance)) {
      montly_expenses +=
          previous_balance - double.parse(transaction_history[i].m_balance);
    } else {
      montly_income +=
          double.parse(transaction_history[i].m_balance) - previous_balance;
    }
    previous_balance = double.parse(transaction_history[i].m_balance);
  }
  double montly_income_percentage =
      montly_income / (montly_income + montly_expenses);
  double montly_expenses_percentage =
      montly_expenses / (montly_income + montly_expenses);

  // Two white containers under Monthly income & expenses
  return Container(
    height: MediaQuery.of(context).size.height * 0.12,
    width: MediaQuery.of(context).size.width * 0.9,
    margin: const EdgeInsets.only(top: 10),
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.12,
          width: MediaQuery.of(context).size.width * 0.425,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 3),
                child: Align(
                  alignment: const Alignment(-0.9, 0),
                  child: CircularPercentIndicator(
                    radius: 30.0,
                    animation: true,
                    animationDuration: 1200,
                    lineWidth: 7.0,
                    percent: montly_income_percentage,
                    center: const Icon(
                      IconData(0xe12c,
                          fontFamily: 'MaterialIcons',
                          matchTextDirection: true),
                      color: msufcuBrightGreen,
                    ),
                    circularStrokeCap: CircularStrokeCap.butt,
                    backgroundColor: const Color.fromARGB(105, 158, 158, 158),
                    progressColor: msufcuBrightGreen,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: const Align(
                        alignment: Alignment(0, 1),
                        child: Text(
                          "Income",
                          style: TextStyle(fontSize: 15),
                        ),
                      )),
                  Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Align(
                        child: Text(
                          '\$$montly_income',
                          style: const TextStyle(fontSize: 20),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.12,
          width: MediaQuery.of(context).size.width * 0.425,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 3),
                child: Align(
                  alignment: const Alignment(-0.9, 0),
                  child: CircularPercentIndicator(
                    radius: 30.0,
                    animation: true,
                    animationDuration: 1200,
                    lineWidth: 7.0,
                    percent: montly_expenses_percentage,
                    center: const Icon(
                      IconData(0xe128,
                          fontFamily: 'MaterialIcons',
                          matchTextDirection: true),
                      color: Colors.red,
                    ),
                    circularStrokeCap: CircularStrokeCap.butt,
                    backgroundColor: const Color.fromARGB(105, 158, 158, 158),
                    progressColor: Colors.pink,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: const Align(
                        alignment: Alignment(0, 1),
                        child: Text(
                          "Expenses",
                          style: TextStyle(fontSize: 15),
                        ),
                      )),
                  Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Align(
                        child: Text(
                          '\$$montly_expenses',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
    // ),
  );
}

Widget MonthlyIncomeAndExpensesError(context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.12,
    width: MediaQuery.of(context).size.width * 0.9,
    margin: EdgeInsets.only(top: 10),
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.12,
          width: MediaQuery.of(context).size.width * 0.425,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 3),
                child: Align(
                  alignment: const Alignment(-0.9, 0),
                  child: CircularPercentIndicator(
                    radius: 30.0,
                    animation: true,
                    animationDuration: 1200,
                    lineWidth: 7.0,
                    percent: 0,
                    center: const Icon(IconData(0xe12c,
                        fontFamily: 'MaterialIcons', matchTextDirection: true)),
                    circularStrokeCap: CircularStrokeCap.butt,
                    backgroundColor: const Color.fromARGB(105, 158, 158, 158),
                    progressColor: const Color.fromARGB(255, 7, 69, 120),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: const Align(
                        alignment: Alignment(0, 1),
                        child: Text(
                          "Income",
                          style: TextStyle(fontSize: 15),
                        ),
                      )),
                  Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: const Align(
                        child: Text(
                          '\$' '0',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.12,
          width: MediaQuery.of(context).size.width * 0.425,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 3),
                child: Align(
                  alignment: const Alignment(-0.9, 0),
                  child: CircularPercentIndicator(
                    radius: 30.0,
                    animation: true,
                    animationDuration: 1200,
                    lineWidth: 7.0,
                    percent: 0,
                    center: const Icon(IconData(0xe128,
                        fontFamily: 'MaterialIcons', matchTextDirection: true)),
                    circularStrokeCap: CircularStrokeCap.butt,
                    backgroundColor: const Color.fromARGB(105, 158, 158, 158),
                    progressColor: Colors.pink,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: const Align(
                        alignment: Alignment(0, 1),
                        child: Text(
                          "Expenses",
                          style: TextStyle(fontSize: 15),
                        ),
                      )),
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: const Align(
                        child: Text(
                          '\$' '0',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
    // ),
  );
}

Future<Widget> balance(context, Future<List<Transaction>> transaction) async {
  List<Transaction> transaction_history = await transaction;
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.15,
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: msufcuForestGreen,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 15, left: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Account balance",
            style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.height * 0.15 * 0.14),
          ),
          Text(
            '\$${transaction_history[transaction_history.length - 1].m_balance}',
            style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.height * 0.15 * 0.4,
                fontWeight: FontWeight.bold),
          ),
        ]),
      ),
    ),
  );
}

Widget balance_widget_while_loading(context, bool isError) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.16,
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: msufcuForestGreen,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Account balance",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          if (isError)
            const Text(
              "Error: No balance",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            )
          else
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              semanticsLabel: 'Circular progress indicator',
            ),
        ]),
      ),
    ),
  );
}
