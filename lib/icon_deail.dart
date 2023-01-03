// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, non_constant_identifier_names, unnecessary_null_comparison, prefer_final_fields, must_be_immutable

import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/msufcu_color_scheme.dart';
import 'package:msufcu_flutter_project/my_offers_screen.dart';
import 'sql/update.dart';

bool isNiButtonClicked = false;

class IconDetail extends StatefulWidget {
  final String _shopName;
  final String _imageLink;
  final String _discountContent;
  String _recommendationReason = "";
  final String _llid;
  final Function _UpdateRecommendedBusinessIdsFromDatabase;

  IconDetail(
      this._shopName,
      this._imageLink,
      this._discountContent,
      this._recommendationReason,
      this._llid,
      this._UpdateRecommendedBusinessIdsFromDatabase,
      {super.key});

  @override
  State<IconDetail> createState() => _IconDetailState();
}

class _IconDetailState extends State<IconDetail> {
  Widget FeedbackMessage() {
    isNiButtonClicked = false;
    return Container(
        padding: EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 10.0),
        child: Text(
            "Thank you for the feedback!  It won't be recommended to you again.",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )));
  }

  /// Icons shown on the local loyalty page of app with the corresponding reccomendations.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _TopBar(widget._shopName),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _ImageDisplay(widget._imageLink),
            _sectionTitle(widget._shopName),
            _sectionText(widget._discountContent, Colors.black),
            if (widget._recommendationReason != "" &&
                widget._recommendationReason != null)
              _sectionTitle("Why is this recommended to you?"),
            _sectionText(widget._recommendationReason, Colors.red),
            if (isNiButtonClicked == true)
              FeedbackMessage()
            else if (isNiButtonClicked == false &&
                widget._recommendationReason != "" &&
                widget._recommendationReason != null)
              ElevatedButton(
                onPressed: () {
                  String m_id = getLoggedInUserId();
                  stopRecommending(m_id, widget._llid);
                  widget._UpdateRecommendedBusinessIdsFromDatabase(
                      widget._llid);

                  setState(() {
                    isNiButtonClicked = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Not interested",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
          ]),
        ));
  }
}

/// Top bar portion of the local loyalty card
class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String _text;
  const _TopBar(this._text);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: BackButton(onPressed: () => {Navigator.pop(context)}),
      title: Text(_text,
          style: TextStyle(
            fontSize: 20,
            color: msufcuForestGreen,
          )),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

/// Displays the logo of the local loyalty business
class _ImageDisplay extends StatelessWidget {
  final String _imageLink;

  const _ImageDisplay(this._imageLink);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.3,
      child: FadeInImage(
        image: NetworkImage(_imageLink),
        fit: BoxFit.fill,
        placeholder: AssetImage(
          "./images/placeholder.svg.png",
        ),
        imageErrorBuilder: (context, error, stackTrace) {
          return Image.asset('./images/placeholder.svg.png', fit: BoxFit.fill);
        },
      ),
    );
  }
}

/// Title for the local loyalty card.
Widget _sectionTitle(String text) {
  return Container(
      padding: EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 10.0),
      child: Text(text,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          )));
}

/// Text that appears below the title
Widget _sectionText(String text, Color textColor) {
  return Container(
      padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 15.0),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
        ),
      ));
}

/// Function that changes reccommendation status of a LL business based on users request.
Future<void> stopRecommending(String m_id, String llid) async {
  Update update = Update();
  await update.singleUpdateInDatabase(
      "recommend",
      "false",
      "recommend",
      """recommend.memberID = '$m_id'
      and recommend.LLID = '$llid'""",
      makeString: false);
}
