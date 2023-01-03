// ignore_for_file: depend_on_referenced_packages, non_constant_identifier_names, must_be_immutable, camel_case_types, prefer_const_constructors_in_immutables, prefer_typing_uninitialized_variables, unnecessary_brace_in_string_interps

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/Classes/triple.dart';
import 'package:msufcu_flutter_project/msufcu_color_scheme.dart';
import 'local_loyality_details.dart';
import 'models/my_offers_icon.dart';
import 'icon_deail.dart';
import 'package:collection/collection.dart';
import 'objects/local_loyalty.dart';
import 'objects/user_info.dart';
import 'objects/local_loyalty_location.dart';
import 'sql/query.dart';

// Mockup data for community events and exclusive offers sections
import 'mocks/mock_my_offers.dart';

final List<MyOffersIcon> communityEventIcons =
    MockMyOffers.FetchCommunityEventsIcons();
final List<MyOffersIcon> exclusiveMemberOfferIcons =
    MockMyOffers.FetchExclusiveOffersIcons();
bool isSortedByLLR = false;

// A widget for the icons on my offers page
class ClickableIcon extends StatelessWidget {
  String shopName;
  String category;
  String imageLink;
  String discountContent;
  bool isRecommended;
  String recommendationReason;
  String llid;
  Function UpdateRecommendedBusinessIdsFromDatabase;

  ClickableIcon({
    super.key,
    required this.shopName,
    required this.category,
    required this.imageLink,
    required this.discountContent,
    required this.isRecommended,
    this.recommendationReason = "",
    required this.llid,
    required this.UpdateRecommendedBusinessIdsFromDatabase,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(children: [
        // Display a image
        imageArea(imageLink, isRecommended),
        // Display the name of the shop
        textArea(
          text: shopName,
        ),
      ]),
      onTap: () {
        // When the icon is clicked, it goes to another page that shows detailed information about the icon that was clicked
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => IconDetail(
                  shopName,
                  imageLink,
                  discountContent,
                  recommendationReason,
                  llid,
                  UpdateRecommendedBusinessIdsFromDatabase)),
        );
      },
    );
  }
}

// A widget that is responsible for displaying the image for the icons on my offers page
class imageArea extends StatelessWidget {
  late final String imageLink;
  late final bool isRecommended;
  imageArea(this.imageLink, this.isRecommended, {super.key});

  // When the local loyalty business is recommended to the user, a thumbs-up image will be shown
  Container _thumbUpDisplay(bool isRecommended, double w, double h) {
    if (isRecommended) {
      return Container(
        margin: const EdgeInsets.only(top: 7, left: 7, right: 7),
        width: w * 0.35,
        height: h * 0.35,
        child: const Image(image: AssetImage('images/thumbs-up.png')),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topRight, children: [
      Container(
        margin: const EdgeInsets.only(top: 7, left: 7, right: 7),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.38,
          height: MediaQuery.of(context).size.height * 0.16,
          child: FadeInImage(
            image: NetworkImage(imageLink),
            fit: BoxFit.fill,
            placeholder: const AssetImage(
              "./images/placeholder.svg.png",
            ),
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset('./images/placeholder.svg.png',
                  fit: BoxFit.fill);
            },
          ),
        ),
      ),
      _thumbUpDisplay(isRecommended, MediaQuery.of(context).size.width * 0.38,
          MediaQuery.of(context).size.height * 0.16)
    ]);
  }
}

// A widget that is responsible for displaying the text for the icons on my offers page
class textArea extends StatelessWidget {
  final String text;
  const textArea({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.38,
            height: MediaQuery.of(context).size.height * 0.06,
            child: Center(
                child: Text(
              text,
              style: const TextStyle(color: Colors.black, fontSize: 13),
            ))));
  }
}

// A widget that displays and controls everything in the exclusive member offers section of my offers page
class ExclusiveMemberOffers extends StatelessWidget {
  const ExclusiveMemberOffers({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
          padding: EdgeInsets.only(left: 10, top: 15, bottom: 5),
          child: Text("EXCLUSIVE MEMBER OFFERS",
              style: TextStyle(fontWeight: FontWeight.bold))),
      Padding(
          padding: const EdgeInsets.only(left: 7),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: getEventsAndExclusiveOffersIcons(exclusiveMemberOfferIcons),
          ))
    ]);
  }
}

// A widget that displays and controls everything in the community events section of my offers page
class CommunityEvents extends StatelessWidget {
  const CommunityEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
          padding: EdgeInsets.only(left: 10, top: 15, bottom: 5),
          child: Text(
            "COMMUNITY EVENTS",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
      Padding(
          padding: const EdgeInsets.only(left: 7),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: getEventsAndExclusiveOffersIcons(communityEventIcons),
          ))
    ]);
  }
}

// A widget that displays and controls everything in the local loyalty of my offers page
class LocalLoyaltySection extends StatelessWidget {
  late List<LocalLoyalty> _localLoyalityiconsData;
  late List<LocalLoyaltyLocation> _localLoyaltyLocationData;
  late List<String> _recommendedBusinessIds;
  late Map<String, String> _recommendationReasons;
  late Function _UpdateRecommendedBusinessIdsFromDatabase;
  LocalLoyaltySection(
      List<LocalLoyalty> localLoyalityiconsData,
      List<LocalLoyaltyLocation> localLoyaltyLocationData,
      List<String> recommendedBusinessIds,
      Map<String, String> recommendationReasons,
      Function UpdateRecommendedBusinessIdsFromDatabase,
      {super.key}) {
    _localLoyalityiconsData = localLoyalityiconsData;
    _localLoyaltyLocationData = localLoyaltyLocationData;
    _recommendedBusinessIds = recommendedBusinessIds;
    _recommendationReasons = recommendationReasons;
    _UpdateRecommendedBusinessIdsFromDatabase =
        UpdateRecommendedBusinessIdsFromDatabase;

    // Sort icons by local loyalty recommendations
    if (isSortedByLLR == false) {
      int pointer = 0;
      for (int i = 1; i < _localLoyalityiconsData.length; i++) {
        if (_recommendedBusinessIds.contains(_localLoyalityiconsData[i].m_id)) {
          _localLoyalityiconsData.swap(pointer, i);
          pointer += 1;
        } else if (_recommendedBusinessIds
            .contains(_localLoyalityiconsData[pointer].m_id)) {
          pointer += 1;
        }
      }
      isSortedByLLR = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 10, top: 15, bottom: 5),
          child: _LocalLoyaltyDetailsBtn(
              "LOCAL LOYALTY >",
              LocalLoyaltyDetails(
                  "LOCAL LOYALTY",
                  _localLoyalityiconsData,
                  _localLoyaltyLocationData,
                  _recommendedBusinessIds,
                  _recommendationReasons,
                  _UpdateRecommendedBusinessIdsFromDatabase))),
      Padding(
          padding: const EdgeInsets.only(left: 7),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: getLocalLoyalityIcons(
                _localLoyalityiconsData,
                _recommendedBusinessIds,
                _recommendationReasons,
                _UpdateRecommendedBusinessIdsFromDatabase),
          ))
    ]);
  }
}

Map<String, String> _recommendationReasons = {};

List<String> getRecommendationReasons() {
  List<String> reasons = [];
  _recommendationReasons.forEach((key, value) {
    reasons.add(value);
  });
  return List.castFrom(reasons);
}

String loggedInUserId = "";

String getLoggedInUserId() {
  return loggedInUserId;
}

class MyOffers extends StatefulWidget {
  final UserInfo loggedInUser;
  List<LocalLoyalty> _localLoyalityiconsData = [];

  List<LocalLoyaltyLocation> _localLoyaltyLocationData = [];

  List<String> _recommendedBusinessIds = [];

  MyOffers({super.key, required this.loggedInUser}) {
    getLocalLoyalityIconsDataFromDatabase();
    // Get local recommendation data here
    getRecommendedBusinessIdsFromDatabase();
    getRecommendedLocalLoyalityRecommendationText();
    getLocationsFromDatabase();
    loggedInUserId = loggedInUser.m_id;
  }

  /// The From statement lets me get the names of the ll company and oon company
  /// I connect the spending table to the ll connections table on oonID
  /// In the where the first statement returns the highest similarity
  /// Also check if the company should be recommended or not
  /// for a specific user, the next part gets the most spent at a company
  /// For example:
  /// s.MemberID	        s.CompanyID	s.Money_Spent	ll.LL_ID	ll.oon_id	ll.similarity
  /// 114P16ZX8HZ9WB43ZG	97	        12.14999962	  15	      97	      0.75
  /// 114P16ZX8HZ9WB43ZG	120	        4.340000153	  15	      120	      0.75
  /// 114P16ZX8HZ9WB43ZG	122	        51.08000183	  15	      122	      0.666667
  /// In this case I want to recommened this user the OONcompany that has the
  /// highest similarity so that would be either 97 or 120, then I want to
  /// use the company they spent the most money at which in this case is 120
  /// The last part connects the LL and OON IDs to their names
  Future<void> getRecommendedLocalLoyalityRecommendationText() async {
    Query query = Query();
    List<Triple<String, String, String>> data =
        await query.recommendedLocalLoyaltyCompanies(
            'll.LL_ID, local_loyalty.name, company.Name',
            """local_loyalty, company, recommend,
            spending s inner join local_loyalty_connections ll on s.CompanyID = ll.OON_ID""",
            true,
            """ (s.MemberID, ll.LL_ID, ll.similarity) in
            (select s.MemberID, ll.LL_ID, max(ll.similarity)
            from spending s inner join local_loyalty_connections ll 
            on s.CompanyID = ll.OON_ID group by s.MemberID, ll.LL_ID)

            and (s.MemberID, ll.similarity, ll.LL_ID, s.Money_Spent) in
            (select s.MemberID, ll.similarity, ll.LL_ID, max(s.Money_Spent)
            from spending s inner join local_loyalty_connections ll 
            on s.CompanyID = ll.OON_ID group by s.MemberID, ll.similarity, ll.LL_ID)

            and local_loyalty.id = ll.LL_ID
            and company.ID = ll.OON_ID
            and recommend.recommend = true and recommend.LLID = ll.LL_ID and recommend.memberID = s.MemberID
            and s.MemberID = '${loggedInUser.m_id}'""");
    for (var i in data) {
      _recommendationReasons[i.first] = FetchRecommendation(i.second, i.third);
    }
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

  /// Query that retreives the recommended local loyalty businesses
  Future<void> getRecommendedBusinessIdsFromDatabase() async {
    Query query = Query();
    List<String> data = await query.recommendedLocalLoyaltyIDQuery(
        'recommend.LLID',
        'recommend inner join user_info on recommend.memberID = user_info.MemberID',
        true,
        "recommend.recommend is true and user_info.MemberID = '${loggedInUser.m_id}'");
    _recommendedBusinessIds = data;
  }

  Future<void> getLocalLoyalityIconsDataFromDatabase() async {
    Query query = Query();
    List<LocalLoyalty> data =
        await query.localLoyaltyQuery("*", "local_loyalty", false, "None");
    _localLoyalityiconsData = data;
  }

  Future<void> getLocationsFromDatabase() async {
    Query query = Query();
    List<LocalLoyaltyLocation> data = await query.localLoyaltyLocationQuery(
        "*", "local_loyalty_location", false, "None");
    _localLoyaltyLocationData = data;
  }

  @override
  State<MyOffers> createState() => _MyOffersState();
}

class _MyOffersState extends State<MyOffers> {
  void _UpdateRecommendedBusinessIdsFromDatabase(String llid) {
    setState(() {
      isSortedByLLR = false;
      for (int i = 0; i < widget._recommendedBusinessIds.length; i++) {
        if (widget._recommendedBusinessIds[i] == llid) {
          widget._recommendedBusinessIds.remove(llid);
          break;
        }
      }
    });
  }

  // Builder for the my offers page
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "My Offers",
        theme:
            ThemeData(primaryColor: msufcuForestGreen, fontFamily: 'OpenSans'),
        home: Scaffold(
            backgroundColor: const Color.fromARGB(58, 158, 158, 158),
            // Things you want to see on the page go inside the "Body" section
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ExclusiveMemberOffers(),
                      const CommunityEvents(),
                      LocalLoyaltySection(
                          widget._localLoyalityiconsData,
                          widget._localLoyaltyLocationData,
                          widget._recommendedBusinessIds,
                          _recommendationReasons,
                          _UpdateRecommendedBusinessIdsFromDatabase),
                    ])),

            // Appbar adds a bar at the top with title and menu bar
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              title: const Text(
                "My Offers",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            )));
  }
}

/// Button that overlays the local loyalty text, sends users to the local loyalty details page
class _LocalLoyaltyDetailsBtn extends StatelessWidget {
  final _appBarText;
  final _page;

  _LocalLoyaltyDetailsBtn(this._appBarText, this._page);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
              text: _appBarText,
              style: const TextStyle(fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()
                ..onTap = () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => _page),
                      )
                    }),
        ],
      ),
    );
  }
}

/// Gets the icons for the events and exclusive offers, these are mainly placeholders
Widget getEventsAndExclusiveOffersIcons(List<dynamic> icons) {
  void temp() {}
  temp();

  List<Widget> list = [];
  for (var i = 0; i < icons.length; i++) {
    list.add(ClickableIcon(
        shopName: icons[i].shopName,
        category: icons[i].category,
        imageLink: icons[i].imageLink,
        discountContent: icons[i].discountContent,
        isRecommended: false,
        llid: i.toString(),
        UpdateRecommendedBusinessIdsFromDatabase: temp));
  }
  return Row(children: list);
}

/// Gets the icons for all the local loyalts businesses
Widget getLocalLoyalityIcons(
    List<LocalLoyalty> icons,
    List<String> recommendedBusinessIds,
    Map<String, String> recommendationReasons,
    Function UpdateRecommendedBusinessIdsFromDatabase) {
  List<Widget> list = [];
  for (var i = 0; i < icons.length; i++) {
    bool isRecommended = recommendedBusinessIds.contains(icons[i].m_id);
    String recommendationReason = "";
    if (isRecommended) {
      if (recommendationReasons[icons[i].m_id] != null) {
        recommendationReason = recommendationReasons[icons[i].m_id] as String;
      }
    }

    list.add(ClickableIcon(
      shopName: icons[i].m_name,
      category: icons[i].m_category_main,
      imageLink: icons[i].m_image_url,
      discountContent: icons[i].m_discount,
      isRecommended: isRecommended,
      recommendationReason: recommendationReason,
      llid: icons[i].m_id,
      UpdateRecommendedBusinessIdsFromDatabase:
          UpdateRecommendedBusinessIdsFromDatabase,
    ));
  }
  return Row(children: list);
}
