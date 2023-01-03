// ignore_for_file: camel_case_types, file_names

class transactionHistory {
  //Instace variables
  int paymentID = 0;
  double amount = 0.0;
  String fullName = "";
  String username = "";
  String sourceName = "";
  String sourceUsername = "";
  String description = "";
  //Status 2 = denied, 1 = accepted, 0 = pending
  int status = 0;
  //bool that checks if the money is coming in or out. State TRUE if coming in FALSE if flowing out
  late bool flowing;
  DateTime time = DateTime.now();

  transactionHistory.associate(Map<String, String?> row) {
    paymentID = int.parse(row["payment_ID"] as String);
    amount = double.parse(row["amount"] as String);
    fullName = row["full_name"] as String;
    username = row["Username"] as String;
    description = row["description"] as String;
    status = int.parse(row["status"] as String);
    flowing = row["flowing"] == "0" ? true : false;
    time = DateTime.parse(row["date"] as String);
    //time = DateFormat('yMd').format(temp);
  }
  //constructor
  transactionHistory(this.amount, this.fullName, this.username,
      this.description, this.status, this.flowing, this.time);

  @override
  String toString() {
    //https://www.cloudhadoop.com/dart-print-object/
    //ignore: unnecessary_brace_in_string_interps
    return '{amount: ${amount}, from: ${sourceName}, to: ${fullName}, description: ${description}, status:${status}, flowing:${flowing}, date:${time}}';
  }
}
