// ignore_for_file: unnecessary_string_escapes

import 'package:msufcu_flutter_project/sql/connection.dart';
import 'package:mysql_client/mysql_client.dart';

import '../objects/user_info.dart';

//Class whose purpose is to authenticate a user
class Auth extends APIConnector {
  //Authentication function to find if a given user's login credentials are a match with those of a user in the database.
  Future<Map<bool, UserInfo>> isMatch(String username, String password) async {
    //Open MySQL connection
    MySQLConnection conn = await openConnection();
    //Query database to look for matching username and password
    var result = await conn.execute(
        "SELECT * FROM user_info where username=\'$username\' and password=\'$password\'");
    //If there's a user with those credentials, then they're authenticated.
    bool isValid = (result.rows.isNotEmpty);
    //Get the information of the user who will be logged in
    UserInfo user = UserInfo(result.rows.first.assoc());
    //Close MySQL connection
    closeConnection(conn);
    Map<bool, UserInfo> userAuth = {isValid: user};
    return userAuth;
  }
}
