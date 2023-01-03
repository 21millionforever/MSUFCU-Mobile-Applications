import 'dart:async';
import 'package:mysql_client/mysql_client.dart';

//Class that serves as a base API connector
class APIConnector {
  APIConnector();

//Opens a connection with the database containing user/transaction records
  Future openConnection() async {
    //For our capstone purposes, we used a CSE MySQL server. However, these connection properties can be easily changed.
    final conn = await MySQLConnection.createConnection(
      host: "35.9.22.104",
      port: 3306,
      userName: "msufcu",
      password: "msufcusql",
      databaseName: "msufcu_db",
    );
    //Await for the connection to be opened
    await conn.connect();
    //Return a connection object
    return conn;
  }

  //Close the connection
  void closeConnection(MySQLConnection conn) async {
    await conn.close();
  }

  //Helper function that will construct a query given certain parameters that will be executed by the API.
  String constructQuery(
      String toSelect, String table, bool usesWhere, String whereClause) {
    //Construct the selection query
    String query = "select $toSelect from $table ";
    //Determine if selecting everything, or just with certain properties
    if (usesWhere) {
      //Append query if necessary
      query += "where $whereClause";
    } else {}
    // print(query);
    return query;
  }

  //Grab all columns of a certain table
  Future<List<String>> getColumns(String table) async {
    //Initialize column list
    List<String> columns = [];
    //Open a connection
    MySQLConnection conn = await openConnection();
    //Execute a SQL statement that grabs columns from a given table
    IResultSet results = await conn.execute(
        "SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'$table'");
    //Get resultset rows
    var rows = results.rows;
    //Iterate over resultset and add to column list
    for (var row in rows) {
      //Grab the associated object
      var col = row.assoc();
      //Add to list
      columns.add(col["COLUMN_NAME"] as String);
    }
    //Close the connection
    conn.close();
    return columns;
  }

  /*For some tables, such as those with generated IDs, we don't care about the first column.
  This function is the same as getColumns(String table), but ignores the first column to avoid generated ID values.*/
  Future<List<String>> getColumnsIgnoreFirst(String table) async {
    List<String> columns = [];
    MySQLConnection conn = await openConnection();
    IResultSet results = await conn.execute(
        "SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'$table'");
    var rows = results.rows;
    bool firstRow = true;
    for (var row in rows) {
      if (!firstRow) {
        var col = row.assoc();
        columns.add(col["COLUMN_NAME"] as String);
      } else {
        firstRow = false;
      }
    }
    conn.close();
    return columns;
  }
}
