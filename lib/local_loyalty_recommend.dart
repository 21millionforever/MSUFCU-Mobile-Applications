// ignore_for_file: non_constant_identifier_names

import 'package:msufcu_flutter_project/sql/connection.dart';
import 'dart:async';
import 'package:mysql_client/mysql_client.dart';
import 'package:msufcu_flutter_project/objects/user_info.dart';

/// This file shows how we used the sql query to get the local loyalty businesses and reccomend them to the user based on their personal spending habits
/// Uncomments the lines in this file to run the code that accomplishes this if reader is curious on how this works!
class LLRecommend {
  Future<String> get_LLRecommend(UserInfo loggedInUser) async {
    APIConnector apiConnector = APIConnector();
    MySQLConnection connect = await apiConnector.openConnection();
    String sqlSelectQuery = """SELECT recommend.LLID
FROM recommend inner join user_info on recommend.memberID = user_info.MemberID
where recommend.recommend is true
and user_info.MemberID = "${loggedInUser.m_id}";""";

    IResultSet results = await connect.execute(sqlSelectQuery);
    var entries = results.rows;

    List<String> recommendedBusinessId = [];

    for (var i in entries) {
      // print(i.assoc()["LLID"]);
      recommendedBusinessId.add(i.assoc()["LLID"].toString());
    }
    return recommendedBusinessId.toString();
  }

  // Future get_LL_company_types() async {
  //   APIConnector apiConnector = APIConnector();

  //   MySQLConnection connect = await apiConnector.openConnection();

  //   String sql_select_Query = """SELECT company.name, company_types.type
  //   from company, company_types, local_loyalty
  //   where company.ID = company_types.ID
  //   and company_types.type != "establishment"`
  //   and company_types.type != "point_of_interest"
  //   and company.ID = local_loyalty.ID
  //   order by company.Name
  //   ;""";

  //   IResultSet results = await connect.execute(sql_select_Query);
  //   var entries = results.rows;

  //   Map<String, Set<String>> LLMap = {};
  //   for (var i in entries) {
  //     // print(i.assoc()["name"]);
  //     // print(i.assoc()["type"]);
  //     if (LLMap.containsKey(i.assoc()["name"])) {
  //       LLMap[i.assoc()["name"].toString()]?.add(i.assoc()["type"].toString());
  //     } else {
  //       LLMap[i.assoc()["name"].toString()] = Set<String>();
  //       LLMap[i.assoc()["name"].toString()]?.add(i.assoc()["type"].toString());
  //     }
  //   }
  //   return LLMap;
  // }

  // Future get_company_types() async {
  //   APIConnector apiConnector = APIConnector();

  //   MySQLConnection connect = await apiConnector.openConnection();

  //   String sql_select_Query = """SELECT company.name, company_types.type
  //   from company, company_types
  //   where company.ID = company_types.ID
  //   and company_types.type != "establishment"
  //   and company_types.type != "point_of_interest"
  //   and company.ID > 79
  //   order by company.Name
  //   ;""";

  //   IResultSet results = await connect.execute(sql_select_Query);
  //   var entries = results.rows;

  //   Map<String, Set<String>> OONMap = {};
  //   for (var i in entries) {
  //     // print(i.assoc()["name"]);
  //     // print(i.assoc()["type"]);
  //     if (OONMap.containsKey(i.assoc()["name"])) {
  //       OONMap[i.assoc()["name"].toString()]?.add(i.assoc()["type"].toString());
  //     } else {
  //       OONMap[i.assoc()["name"].toString()] = Set<String>();
  //       OONMap[i.assoc()["name"].toString()]?.add(i.assoc()["type"].toString());
  //     }
  //   }
  //   return OONMap;
  // }

  // Future<String> get_LLRecommend() async {
  //   Map<String, Set<String>> LLMap = await get_LL_company_types();
  //   Map<String, Set<String>> OONMap = await get_company_types();
  //   List<String> LLData = [];
  //   for (var LL in LLMap.keys) {
  //     for (var OON in OONMap.keys) {
  //       Set<String>? union = LLMap[LL]?.union(OONMap[OON] as Set<String>);
  //       Set<String>? inter =
  //           LLMap[LL]?.intersection(OONMap[OON] as Set<String>);
  //       int inter_len = inter!.length;
  //       int union_len = union!.length;
  //       double suggest_percent = inter_len / union_len;
  //       if (suggest_percent > 0.9) {
  //         // ${suggest_percent * 100}%
  //         String data =
  //             'Local Loyalty: ${LL} ${LLMap[LL]} \nOut Of Network: ${OON} ${OONMap[OON]}\n\n';
  //         // print(data);
  //         LLData.add(data);
  //       }
  //     }
  //   }
  //   // print(LLData);
  //   return LLData.join();
  // }
}
