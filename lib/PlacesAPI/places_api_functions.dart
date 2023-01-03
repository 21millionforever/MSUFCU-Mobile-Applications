import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Classes/pair.dart';

class PlacesAPIResponse {
  /// Name of company searched
  String companyName = "";

  /// If the company was found by PlacesAPI
  bool companyFound = false;

  /// Number of times company appeared in transaction list
  int companyAppearCount = 1;

  /// Tags associated with a company
  Set<String> tags = {};

  PlacesAPIResponse(
      Set<String> typesSet, bool foundCompany, String company, int companyNum) {
    tags = typesSet;
    companyFound = foundCompany;
    companyName = company;
    companyAppearCount = companyNum;
  }

  @override
  String toString() {
    return "{companyName: $companyName; companyFound: $companyFound; companyAppearCount: $companyAppearCount; types: $tags}";
  }
}

/// Takes a list of company names and retrieves identifiers if they exist in
/// Google's Places API, sets flag 'companyFound' based on if company is found
/// or not
Future<List<PlacesAPIResponse>> retrieveCompanyIdentifiers(
    List<Pair<String, int>> companyNames) async {
  List<PlacesAPIResponse> companies = [];

  var client = http.Client();

  // Google Places API Key
  String apiKey = "";

  for (var company in companyNames) {
    // Object containing information pertaining to a specific company
    PlacesAPIResponse companyIdentifiers =
        PlacesAPIResponse({}, false, company.first, company.second);

    // URL to call Google Maps API with formatted to input a company
    String url =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=${company.first}&fields=type&inputtype=textquery&key=$apiKey";

    var response = await client.get(Uri.parse(url));

    // If request is good, continue
    if (response.statusCode == 200) {
      // Try to decode response and get list of types
      try {
        // Decode json object to a list of types
        List<dynamic> typesList =
            jsonDecode(response.body)['candidates'][0]['types'];

        // Add each company type to a set as Strings
        for (var type in typesList) {
          companyIdentifiers.tags.add(type as String);
        }
        companyIdentifiers.companyFound = true;

        // If company searched not found, throw an exception
        // that company name was invalid
      } on RangeError {
        companyIdentifiers.companyFound = false;
      }
      // Else throw an execption with the HTTP Error's status code
    } else {
      throw Exception("HTTP Error: ${response.statusCode}");
    }
    companies.add(companyIdentifiers);
  }

  client.close();

  return companies;
}
