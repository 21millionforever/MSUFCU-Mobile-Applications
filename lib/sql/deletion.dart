import 'package:mysql_client/mysql_client.dart';

import 'connection.dart';

//Class whose purpose is to remove a record (for transaction histories)
class Deletion extends APIConnector {
  Deletion();

  //Deletes a record in the database with a given condition in a given table
  Future<void> deleteInDatabase(String table, String condition) async {
    //SQL deletion statement
    String statement = "DELETE FROM $table WHERE $condition";
    //Open SQL connection
    MySQLConnection conn = await openConnection();
    //Execute SQL statement
    await conn.execute(statement);
    //Close connection
    conn.close();
  }
}
