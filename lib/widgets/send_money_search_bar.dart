import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/send_money.dart';

import '../msufcu_color_scheme.dart';
import '../objects/user_info.dart';
import '../sql/query.dart';

/// Creates a search bar that allows users to search the entire database
/// for other members they can send money to
class SearchBar extends StatefulWidget {
  const SearchBar({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController searchBarController = getSearchBarController();
  final ValueNotifier<bool> refreshingPage = getRefreshingPageNotifier();

  // Search database for users based on user's search query
  Future<List<UserInfo>> searchDatabaseForUser() async {
    Query query = Query();

    List<UserInfo> searchedUsers = [];

    if (searchBarController.text.isNotEmpty) {
      searchedUsers = await query.userInfoQuery("*", 'user_info', true,
          """(full_name LIKE '${searchBarController.text}%' OR Username LIKE '${searchBarController.text}%' 
        OR Email LIKE '${searchBarController.text}%' OR `Phone_Number` LIKE '${searchBarController.text}%') AND MemberID NOT LIKE '${widget.loggedInUser.m_id}' ORDER BY full_name""");
    }
    return searchedUsers;
  }

  void changeDisplaysOnTap() {
    displayedUsers.value = [];
    setState(() {
      searchingUsers.value = true;
    });
  }

  void changeDisplaysOnSubmit(String value) {
    setState(() {
      if (value.isEmpty) {
        searchingUsers.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 15),
        child: FractionallySizedBox(
            widthFactor: 0.9,
            child: SizedBox(
                height: 38,
                child: ValueListenableBuilder(
                    builder: (BuildContext context, bool value, Widget? child) {
                      return TextField(
                          enabled: !refreshingPage.value,
                          onSubmitted: (value) => changeDisplaysOnSubmit(value),
                          onTap: () => changeDisplaysOnTap(),
                          onChanged: (value) => searchDatabaseForUser()
                              .then((value) => displayedUsers.value = value),
                          autocorrect: false,
                          enableSuggestions: false,
                          controller: searchBarController,
                          cursorColor: msufcuBrightGreen,
                          style: const TextStyle(color: Colors.black),
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.bottom,
                          decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.black),
                              hintText: "Name, @username, email, phone",
                              hintMaxLines: 1,
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: msufcuForestGreen),
                                  borderRadius: BorderRadius.circular(5))));
                    },
                    valueListenable: refreshingPage))));
  }
}
