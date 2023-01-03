// ignore_for_file: non_constant_identifier_names

//This class describes a local loyalty object which corresponds to the local_loyalty table in the database
class LocalLoyalty {
  String m_id = '';
  String m_category_main = '';
  String m_category_secondary = '';
  String m_name = '';
  String m_discount = '';
  String m_image_url = '';

  //Query the row using the column names from the database table and assign variables to their columns
  LocalLoyalty(Map<String, String?> row) {
    m_id = row["id"] as String;
    m_category_main = row["main_category"] as String;
    m_category_secondary = row["secondary_category"] as String;
    m_name = row["name"] as String;
    m_discount = row["discount"] as String;
    m_image_url = row["image_url"] as String;
  }

  @override
  String toString() {
    //https://www.cloudhadoop.com/dart-print-object/
    //ignore: unnecessary_brace_in_string_interps
    return '{m_id: ${m_id}, main_category: ${m_category_main}, secondary_category: ${m_category_secondary}, name: ${m_name}, discount: ${m_discount}, image_url: ${m_image_url}}';
  }
}
