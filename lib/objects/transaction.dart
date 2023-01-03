// ignore_for_file: non_constant_identifier_names

//This class describes a transaction object which corresponds to the transaction table in the database
class Transaction {
  String m_id = '';
  String m_date = '';
  String m_merchant = '';
  String m_amount = '';
  String m_description = '';
  String m_balance = '';
  String m_transaction_id = '';

  //Query the row using the column names from the database table and assign variables to their columns
  Transaction(Map<String, String?> row) {
    m_id = row["MemberID"] as String;
    m_date = row["Date"] as String;
    m_merchant = row["Merchant"] as String;
    m_amount = row["Amount"] as String;
    m_description = row["Description"] as String;
    m_balance = row["Balance"] as String;
    m_transaction_id = row["TransactionID"] as String;
  }

  @override
  String toString() {
    //https://www.cloudhadoop.com/dart-print-object/
    //ignore: unnecessary_brace_in_string_interps
    return '{m_id: ${m_id}, date: ${m_date}, merchant: ${m_merchant}, amount: ${m_amount}, description: ${m_description}, balance: ${m_balance}, transaction_id:${m_transaction_id}}';
  }
}
