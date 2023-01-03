// ignore_for_file: non_constant_identifier_names

//This class describes a contact object which corresponds to the contact table in the database
class Contact {
  String m_id = '';
  String m_connected_user = '';
  String m_favorite = '';
  String m_last_contacted = '';

  //Query the row using the column names from the database table and assign variables to their columns
  Contact(Map<String, String?> row) {
    m_id = row["id_user"] as String;
    m_connected_user = row["connected_user"] as String;
    m_favorite = row["favorite"] as String;
    m_last_contacted = row["last_contacted"] as String;
  }

  @override
  String toString() {
    //https://www.cloudhadoop.com/dart-print-object/
    //ignore: unnecessary_brace_in_string_interps
    return '{m_id: ${m_id}, connected_user: ${m_connected_user}, favorite: ${m_favorite}, last_contacted: ${m_last_contacted}}';
  }
}
