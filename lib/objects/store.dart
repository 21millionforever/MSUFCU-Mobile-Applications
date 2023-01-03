// ignore_for_file: non_constant_identifier_names

//This class describes a store object which corresponds to the store table in the database
class Store {
  String m_company_id = '';
  String m_location = '';
  String m_local_loyalty = '';
  String m_store_id = '';

  //Query the row using the column names from the database table and assign variables to their columns
  Store(Map<String, String?> row) {
    m_company_id = row["CompanyID"] as String;
    m_location = row["Location"] as String;
    m_local_loyalty = row["LocalLoyalty"] as String;
    m_store_id = row["StoreID"] as String;
  }

  @override
  String toString() {
    //https://www.cloudhadoop.com/dart-print-object/
    //ignore: unnecessary_brace_in_string_interps
    return '{company_id: ${m_company_id}, location: ${m_location}, local_loyalty: ${m_local_loyalty}, store_id: ${m_store_id}}';
  }
}
