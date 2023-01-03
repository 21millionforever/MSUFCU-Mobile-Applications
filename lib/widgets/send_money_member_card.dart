import 'package:flutter/material.dart';

import 'favorite_button.dart';
import 'user_identifier.dart';
import '../msufcu_color_scheme.dart';
import '../objects/user_info.dart';
import '../send_amount_page.dart';
import '../send_money.dart';

class MemberCardWithFavorite extends StatefulWidget {
  const MemberCardWithFavorite(
      {super.key, required this.user, required this.loggedInUser});

  final UserInfo user;
  final UserInfo loggedInUser;

  @override
  State<MemberCardWithFavorite> createState() => _MemberCardWithFavoriteState();
}

class _MemberCardWithFavoriteState extends State<MemberCardWithFavorite> {
  @override
  Widget build(BuildContext context) {
    List<String> splitName = widget.user.m_full_name.split(" ");
    return Row(children: [
      FavoriteButton(
        favorited: getFavoritedUserSet().contains(widget.user.m_id),
          loggedInUser: widget.loggedInUser,
          connectedUser: widget.user),

      // Create stack with circle behind user's initials
      Stack(alignment: Alignment.center, children: [
        const Icon(size: 50, color: msufcuForestGreen, Icons.circle),
        Text("${splitName.first[0]}${splitName.last[0]}",
            style: const TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold))
      ]),
      Flexible(
          child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: UserIdentifier(
                  user: widget.user,
                  fontWeight: FontWeight.normal,
                  crossAxis: CrossAxisAlignment.start,
                  mainAxis: MainAxisAlignment.center)))
    ]);
  }
}

class MemberCardWithoutFavorite extends StatefulWidget {
  const MemberCardWithoutFavorite({super.key, required this.user});

  final UserInfo user;

  @override
  State<MemberCardWithoutFavorite> createState() =>
      _MemberCardWithoutFavoriteState();
}

class _MemberCardWithoutFavoriteState extends State<MemberCardWithoutFavorite> {
  @override
  Widget build(BuildContext context) {
    List<String> splitName = widget.user.m_full_name.split(" ");
    return Row(
      children: [
        // Create stack with circle behind user's initials
        Stack(alignment: Alignment.center, children: [
          const Icon(size: 50, color: msufcuForestGreen, Icons.circle),
          Text("${splitName.first[0]}${splitName.last[0]}",
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold))
        ]),
        Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: UserIdentifier(
                user: widget.user,
                fontWeight: FontWeight.normal,
                crossAxis: CrossAxisAlignment.start,
                mainAxis: MainAxisAlignment.center))
      ],
    );
  }
}

/// Creates a card with a member's name, username, and a favorites button
class MemberCard extends StatefulWidget {
  MemberCard({super.key, required this.user, required this.loggedInUser});

  final UserInfo user;
  final UserInfo loggedInUser;
  final ValueNotifier<bool> searchingUsers = getSearchingUsersNotifier();

  @override
  State<MemberCard> createState() => _MemberCardState();
}

// Allows for members to be selected with a tap of their card
class _MemberCardState extends State<MemberCard> {
  // Insert a new connection into the database
  void addNewContactConnection() {}

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return SendAmountPage(
                  destUser: widget.user,
                  sourceUser: widget.loggedInUser,
                  fromScan: false,
                );
              })),
            },
        child: widget.searchingUsers.value
            ? MemberCardWithoutFavorite(user: widget.user)
            : MemberCardWithFavorite(
                user: widget.user, loggedInUser: widget.loggedInUser));
  }
}
