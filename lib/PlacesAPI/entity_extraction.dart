import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/PlacesAPI/places_api_functions.dart';
import 'package:msufcu_flutter_project/sql/query.dart';

import '../Classes/pair.dart';
import '../objects/transaction.dart';

/// Returns a map of every entry in the database, gives empty merchant columns
/// a value to distinguish them from other empty merchant entries.
Future<Map<String, List<List<String>>>> getMerchantDescriptionPairs() async {
  Query query = Query();

  List<Transaction> transactions = [];
  Map<String, List<List<String>>> merchantDescriptionPairs = {};

  await query
      .transactionQuery("*", "transaction", false, "")
      .then((value) => transactions = value)
      .whenComplete(() => {
            for (int i = 0; i < transactions.length; i++)
              {
                if (merchantDescriptionPairs
                    .containsKey(transactions[i].m_merchant))
                  {
                    if (transactions[i].m_description != "||||")
                      {
                        merchantDescriptionPairs[transactions[i].m_merchant]!
                            .add(transactions[i].m_description.split("||||"))
                      }
                    else
                      {
                        merchantDescriptionPairs[transactions[i].m_merchant]!
                            .add([])
                      }
                  }
                else
                  {
                    if (transactions[i].m_description != "||||")
                      {
                        merchantDescriptionPairs[transactions[i].m_merchant] = [
                          transactions[i].m_description.split("||||")
                        ]
                      }
                    else
                      {
                        merchantDescriptionPairs[transactions[i].m_merchant] = [
                          []
                        ]
                      }
                  }
              }
          });

  return merchantDescriptionPairs;
}

/// Determines if a string value is numerical
bool isNumeric(String num) {
  try {
    double.parse(num);
    return true;
  } on FormatException {
    return false;
  }
}

/// Returns a map of the companies in the database after removing entries that
/// do not have any identifiying information about a company. Companies with
/// no merchant can still have a description that may contain company name.
/// Need to create further functions to extrapolate company from description
Future<Map<String, List<List<String>>>> getInformativePairs() async {
  Map<String, List<List<String>>> merchantDescriptions = {};

  Map<String, List<List<String>>> informativePairs = {};

  await getMerchantDescriptionPairs()
      .then((value) => merchantDescriptions = value);

  for (var merchant in merchantDescriptions.keys) {
    List<List<String>> savedTransactions = [];
    if (merchant.contains("To Share") || merchant.contains('To Loan')) {
      continue;
    } else if (isNumeric(merchant)) {
      // If the merchant is numeric, check if the description has useful
      // information to determine the company by. If so, save it. Otherwise,
      // skip that transaction
      for (var transaction in merchantDescriptions[merchant]!) {
        if (transaction.isNotEmpty) {
          savedTransactions.add(transaction);
        }
      }
      if (savedTransactions.isNotEmpty) {
        informativePairs[merchant] = savedTransactions;
      }
    } else if (merchant.isEmpty) {
      /// If the merchant is empty, check if the description has useful
      /// information to determine the company by. If so, save it. Otherwise,
      /// skip that transaction
      for (var transaction in merchantDescriptions[merchant]!) {
        if (transaction.isNotEmpty) {
          savedTransactions.add(transaction);
        }
      }

      if (savedTransactions.isNotEmpty) {
        informativePairs[merchant] = savedTransactions;
      }
    } else {
      informativePairs[merchant] =
          merchantDescriptions[merchant] as List<List<String>>;
    }
  }

  return informativePairs;
}

/// Searches companies in database and returns whether or not PlacesAPI could
/// find those companies
void searchCompanies() async {
  Map<String, List<List<String>>> pairs = {};

  List<Pair<String, int>> companyNames = [];

  await getInformativePairs().then((value) => pairs = value);

  // Set to 10 just for quick demonstration. Change to pairs.length for
  // all companies
  for (int i = 0; i < 10; i++) {
    companyNames.add(
        Pair(pairs.keys.toList()[i], pairs[pairs.keys.toList()[i]]!.length));
  }

  List<PlacesAPIResponse> response =
      await retrieveCompanyIdentifiers(companyNames);

  for (var item in response) {
    if (item.companyFound) {
      debugPrint(item.toString());
    }
  }
}
