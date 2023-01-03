// ignore_for_file: non_constant_identifier_names

//This class describes a spending object which corresponds to the spending table in the database
class Spending {
  String m_id = '';
  String m_company_id = '';
  String m_money_spent = '';
  String m_store_id = '';

  //Query the row using the column names from the database table and assign variables to their columns
  Spending(Map<String, String?> row) {
    m_id = row["MemberID"] as String;
    m_company_id = row["CompanyID"] as String;
    m_money_spent = row["Money_Spent"] as String;
  }

  @override
  String toString() {
    //https://www.cloudhadoop.com/dart-print-object/
    //ignore: unnecessary_brace_in_string_interps
    return '{m_id: ${m_id}, company_id: ${m_company_id}, money_spent: ${m_money_spent}}';
  }
}
