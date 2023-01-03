import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/send_money.dart';

import '../msufcu_color_scheme.dart';
import '../objects/user_info.dart';
import '../sql/update.dart';

class FavoritedIcon extends StatelessWidget {
  const FavoritedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: AlignmentDirectional.center, children: const [
      Center(child: Icon(Icons.star, color: Colors.yellow, size: 40)),
      Center(child: Icon(Icons.star_border_outlined, size: 40))
    ]);
  }
}

// ignore: must_be_immutable
class FavoriteButton extends StatefulWidget {
  FavoriteButton(
      {super.key,
      required this.favorited,
      required this.loggedInUser,
      required this.connectedUser});

  bool favorited;
  final UserInfo loggedInUser;
  final UserInfo connectedUser;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  void toggleFavorite() async {
    setState(() {
      widget.favorited = !widget.favorited;
    });

    Update update = Update();
    await update.singleUpdateInDatabase(
        'favorite',
        widget.favorited ? "1" : "0",
        'contact',
        "id_user = '${widget.loggedInUser.m_id}' AND connected_user = '${widget.connectedUser.m_id}'");
    getConnectedUsers(widget.loggedInUser);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        padding: EdgeInsets.zero,
        onPressed: () => toggleFavorite(),
        isSelected: widget.favorited,
        iconSize: 40,
        color: msufcuForestGreen,
        icon: const Icon(Icons.star_border_outlined),
        selectedIcon: const FavoritedIcon());
  }
}
