// ignore_for_file: non_constant_identifier_names

import 'package:msufcu_flutter_project/Classes/transactionHistory.dart';
import 'package:msufcu_flutter_project/objects/local_loyalty.dart';
import 'package:msufcu_flutter_project/objects/m2m_payment.dart';
import 'package:msufcu_flutter_project/objects/spending.dart';
import 'package:msufcu_flutter_project/objects/store.dart';
import 'package:msufcu_flutter_project/sql/connection.dart';
import 'package:mysql_client/mysql_client.dart';

import '../Classes/triple.dart';
import '../objects/company.dart';
import '../objects/contact.dart';
import '../objects/local_loyalty_location.dart';
import '../objects/transaction.dart';
import '../objects/user_info.dart';

class Query extends APIConnector {
  //General query, can be used for anything. Returns whatever it's querying
  //Returns an IResultSet that, if you're using this function for something outside
  //of helper/wrapper functions, you would need to decode/provide associations for yourself
  //Not really meant for use outside of wrapper functions, but highhly customizable
  Future<IResultSet> selectQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    //Open MySQL connection
    MySQLConnection conn = await openConnection();
    //Construct query
    String query = constructQuery(toSelect, table, usesWhere, whereClause);
    //Execute query
    var result = await conn.execute(query);

    conn.close();

    return result;
  }

  //Returns a List<Company> of queried companies given parameters
  Future companyQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<Company> companies = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      Company newCompany = Company(i.assoc());
      companies.add(newCompany);
    }
    return companies;
  }

  //Returns a List<Contact> of queried contacts given parameters
  Future contactQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<Contact> contacts = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      Contact newContact = Contact(i.assoc());
      contacts.add(newContact);
    }
    return contacts;
  }

  //Returns a List<LocalLoyalty> of queried local loyalties given parameters
  Future<List<LocalLoyalty>> localLoyaltyQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<LocalLoyalty> loyalties = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      LocalLoyalty newLoyalty = LocalLoyalty(i.assoc());
      loyalties.add(newLoyalty);
    }
    return loyalties;
  }

  //Returns a List<String> of all the possible local loyalties
  Future getLocalLoyaltyImages() async {
    List<LocalLoyalty> loyalties =
        await localLoyaltyQuery("*", "local_loyalty", false, "");
    List<String> urls = [];
    for (LocalLoyalty localLoyalty in loyalties) {
      urls.add(localLoyalty.m_image_url);
    }
    return urls;
  }

//Returns a Map<LL_Name, LL_Img_URL> of all possible local loyalties
  Future getLocalLoyaltyMap() async {
    List<LocalLoyalty> loyalties =
        await localLoyaltyQuery("*", "local_loyalty", false, "");
    List<Map<String, String>> pairings = [];
    for (LocalLoyalty localLoyalty in loyalties) {
      Map<String, String> pairing = {
        localLoyalty.m_name: localLoyalty.m_image_url
      };
      pairings.add(pairing);
    }
    return pairings;
  }

  //Returns a List<LocalLoyaltyLocation> of queried local loyalty locations given parameters
  Future localLoyaltyLocationQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<LocalLoyaltyLocation> loyaltyLocations = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      LocalLoyaltyLocation newLoyaltyLocation = LocalLoyaltyLocation(i.assoc());
      loyaltyLocations.add(newLoyaltyLocation);
    }
    return loyaltyLocations;
  }

  //Returns a List<M2MPayment> of queried payments given parameters
  Future m2mPaymentQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<M2MPayment> payments = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      M2MPayment newPayment = M2MPayment(i.assoc());
      payments.add(newPayment);
    }
    return payments;
  }

  //Returns a List<M2MPayment> of queried payments given parameters
  Future m2mQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<transactionHistory> payments = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      transactionHistory newPayment = transactionHistory.associate(i.assoc());
      payments.add(newPayment);
    }
    return payments;
  }

  //Returns a List<Spending> of queried spendings given parameters
  Future spendingQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<Spending> spendings = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      Spending newSpending = Spending(i.assoc());
      spendings.add(newSpending);
    }
    return spendings;
  }

  //Returns a List<Store> of queried stores given parameters
  Future storeQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<Store> stores = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      Store newStore = Store(i.assoc());
      stores.add(newStore);
    }
    return stores;
  }

  //Returns a List<Transaction> of queried transactions given parameters
  Future transactionQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<Transaction> transactions = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      Transaction newTransaction = Transaction(i.assoc());
      transactions.add(newTransaction);
    }
    return transactions;
  }

  //Returns a List<UserInfo> of queried stores given parameters
  Future userInfoQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<UserInfo> users = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      UserInfo newUser = UserInfo(i.assoc());
      users.add(newUser);
    }
    return users;
  }

  /// Returns a List<Triple<UserInfo, String, int>> that provides significant
  /// speedup to sorting functions by retrieving every connected user and their
  /// user info at once rather than seperately
  Future joinedUserInfoContactQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<Triple<UserInfo, String, int>> contacts = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      UserInfo user = UserInfo(i.assoc());
      Triple<UserInfo, String, int> triple = Triple(
          user,
          i.colByName('favorite') as String,
          int.parse(i.colByName('last_contacted') as String));
      contacts.add(triple);
    }

    return contacts;
  }

  /// Returns a boolean value of true if a push notification should be sent,
  /// or false if one should not be sent to all devices
  Future<bool> pushNotificationDatabaseQuery() async {
    IResultSet result =
        await selectQuery("*", "push_notification_notifier", true, "ID = 2");
    var entries = result.rows;

    return entries.elementAt(0).colByName("send_push") == "1" ? true : false;
  }

  /// Returns a List<String> that is used to know which
  /// LL companies to reccomend to the logged in user
  Future recommendedLocalLoyaltyIDQuery(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<String> ids = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      String newI = i.assoc().values.first as String;
      // print(newI + " type: " + newI.runtimeType.toString());
      ids.add(newI);
    }

    return ids;
  }

  /// Returns a list of triples that store connections between the user
  /// and what should be recommended to them
  /// First string is LLID, Second is name of LL, Thrid is name of OON
  Future recommendedLocalLoyaltyCompanies(
      String toSelect, String table, bool usesWhere, String whereClause) async {
    List<Triple<String, String, String>> recommendedComapnies = [];
    IResultSet results =
        await selectQuery(toSelect, table, usesWhere, whereClause);
    var entries = results.rows;
    for (var i in entries) {
      String LL_ID = i.assoc()["LL_ID"].toString();
      String LL_Name = i.assoc()["name"].toString();
      String OON_Name = i.assoc()["Name"].toString();
      Triple<String, String, String> data = Triple(LL_ID, LL_Name, OON_Name);
      recommendedComapnies.add(data);
    }

    return recommendedComapnies;
  }
}
