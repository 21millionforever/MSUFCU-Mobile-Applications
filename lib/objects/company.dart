// ignore_for_file: non_constant_identifier_names

//This class describes a company object which corresponds to the company table in the database
class Company {
  String m_id = '';
  String m_name = '';
  String m_service = '';

  //Query the row using the column names from the database table and assign variables to their columns
  Company(Map<String, String?> row) {
    m_id = row["ID"] as String;
    m_name = row["Name"] as String;
    m_service = row["Service"] as String;
  }

  @override
  String toString() {
    //https://www.cloudhadoop.com/dart-print-object/
    //ignore: unnecessary_brace_in_string_interps
    return '{m_id: ${m_id}, name: ${m_name}, service: ${m_service}}';
  }
}
