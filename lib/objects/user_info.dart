// ignore_for_file: non_constant_identifier_names

//This class describes a User Info object which corresponds to the user_info table in the database
class UserInfo {
  String m_id = '';
  String m_username = '';
  String m_password = '';
  String m_full_name = '';
  String m_email = '';
  String m_qr = '';
  String m_phone = '';

  //Query the row using the column names from the database table and assign variables to their columns
  UserInfo(Map<String, String?> row) {
    m_id = row["MemberID"] as String;
    m_username = row["Username"] as String;
    m_password = row["Password"] as String;
    m_full_name = row["full_name"] as String;
    m_email = row["Email"] as String;
    m_qr = row["QR_Code"] as String;
    m_phone = row["Phone_Number"] as String;
  }

  @override
  String toString() {
    //https://www.cloudhadoop.com/dart-print-object/
    //ignore: unnecessary_brace_in_string_interps
    return '{m_id: ${m_id}, username: ${m_username}, password: ${m_password}, full_name: ${m_full_name}, email: ${m_email}, qr: ${m_qr}, phoneNumber: ${m_phone}}';
  }
}
