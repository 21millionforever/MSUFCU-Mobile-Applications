// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unused_import

import "dart:math";

class MockLocalLoyalityRecommendation {
  static List<String> FetchRecommendatedBusinessIds() {
    return ['1', '3', '7'];
  }

  static Map<String, String> FetchReasons() {
    return {
      '1': "Because you shopped at auto zone you should try Ryan's Auto Care",
      '3': "Because you shopped at auto zone, you should try Ryan's Auto Care",
      '7': "Because you shopped at auto zone, you should try Ryan's Auto Care"
    };
  }

  static String FetchRecommendation(String ll, String oon) {
    var list = [
      "Because you shopped at ${oon}, you should try ${ll}!",
      "We encourage visiting ${ll}, since you like shopping at ${oon}!",
      "Consider trying ${ll}, since you like shopping at ${oon}!",
      "Have you heard about ${ll}? It is similar to ${oon}!",
      "We think you might like ${ll}, since you like shopping at ${oon}!",
      "Like ${oon}? It is similar to ${ll}!",
      "Hey you should drop by ${ll}, it is similar to ${oon}!",
      "Consider ${ll} it is comparable to ${oon}!",
    ];

    var randomItem = (list..shuffle()).first;
    return randomItem;
  }
  //ll company name, oon company name: completed string
}
