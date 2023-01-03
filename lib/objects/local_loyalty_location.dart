// ignore_for_file: non_constant_identifier_names

//This class describes a local loyalty location object which corresponds to the local_loyalty_location table in the database
class LocalLoyaltyLocation {
  String m_id = '';
  String m_region = '';
  String m_location = '';
  String m_latitude = '';
  String m_longitude = '';

  //Query the row using the column names from the database table and assign variables to their columns

  LocalLoyaltyLocation(Map<String, String?> row) {
    m_id = row["local_loyalty_id"] as String;
    m_region = row["region"] as String;
    m_location = row["location"] as String;
    m_latitude = row["latitude"] as String;
    m_longitude = row["longitude"] as String;
  }

  @override
  String toString() {
    //https://www.cloudhadoop.com/dart-print-object/
    //ignore: unnecessary_brace_in_string_interps
    return '{ll_id: ${m_id}, region: ${m_region}, location: ${m_location}, latitude: ${m_latitude}, longitude: ${m_longitude}}';
  }
}
