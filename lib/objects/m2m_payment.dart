// ignore_for_file: non_constant_identifier_names

//This class describes an M2M payment object which corresponds to the m2m_payment table in the database
class M2MPayment {
  String m_payment_id = '';
  String m_from = '';
  String m_to = '';
  String m_amount = '';
  String m_date = '';
  String m_description = '';

  //Query the row using the column names from the database table and assign variables to their columns
  M2MPayment(Map<String, String?> row) {
    m_payment_id = row["payment_ID"] as String;
    m_from = row["from"] as String;
    m_to = row["to"] as String;
    m_amount = row["amount"] as String;
    m_date = row["date"] as String;
    m_description = row["description"] as String;
  }

  @override
  String toString() {
    //https://www.cloudhadoop.com/dart-print-object/
    //ignore: unnecessary_brace_in_string_interps
    return '{payment_id: ${m_payment_id}, from: ${m_from}, to: ${m_to}, amount: ${m_amount}, date:${m_date}, description:${m_description}}';
  }
}
