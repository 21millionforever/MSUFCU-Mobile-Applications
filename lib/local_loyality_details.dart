// ignore_for_file: unused_local_variable, must_be_immutable, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, prefer_const_constructors, sized_box_for_whitespace, prefer_typing_uninitialized_variables, unused_field, camel_case_types, prefer_final_fields
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/objects/local_loyalty_location.dart';
import './msufcu_color_scheme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'icon_deail.dart';
import 'objects/local_loyalty.dart';

/// Checks for location permissions within the devices and if granted will get the current position of the phone
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition();
}

Map<String, double> businessToPhone = {};

/// Gets the current location from the phone
void getCurrentLocation() async {
  Position position = await _determinePosition();
}

late Position _phonePosition;

class LocalLoyaltyDetails extends StatefulWidget {
  List<LocalLoyalty> _SelectedLocalLotalityData = [];
  late Function _UpdateRecommendedBusinessIdsFromDatabase;
  late List<String> _recommendatedBusinessIds;
  late final String _barTitle;
  late final List<LocalLoyalty> _localLoyalityData;
  late final List<LocalLoyaltyLocation> _localLoyaltyLocationData;
  late Map<String, String> _recommendationReasons;

  LocalLoyaltyDetails(
      String barTitle,
      List<LocalLoyalty> localLoyalityData,
      List<LocalLoyaltyLocation> localLoyaltyLocationData,
      List<String> recommendatedBusinessIds,
      Map<String, String> recommendationReasons,
      Function UpdateRecommendedBusinessIdsFromDatabase,
      {super.key}) {
    _barTitle = barTitle;
    _localLoyalityData = localLoyalityData;
    _SelectedLocalLotalityData = localLoyalityData;
    _localLoyaltyLocationData = localLoyaltyLocationData;
    _recommendatedBusinessIds = recommendatedBusinessIds;
    _recommendationReasons = recommendationReasons;

    GetDistanceBetweenPhoneAndBusiness(
        localLoyalityData, localLoyaltyLocationData);
    _UpdateRecommendedBusinessIdsFromDatabase =
        UpdateRecommendedBusinessIdsFromDatabase;
  }

  @override
  State<LocalLoyaltyDetails> createState() => _LocalLoyaltyDetailsState();
}

class _LocalLoyaltyDetailsState extends State<LocalLoyaltyDetails> {
  void _UpdateAfterNiButtonClicked(String llid) {
    setState(() {
      widget._UpdateRecommendedBusinessIdsFromDatabase(llid);
    });
  }

  void _ChangeSelectedLocalLoyalityData(
      List<LocalLoyalty> newSelectedLocalLoyalityData) {
    setState(() {
      widget._SelectedLocalLotalityData = newSelectedLocalLoyalityData;
    });
  }

  void futureDeterminePosition() async {
    _phonePosition = await _determinePosition();
  }

  @override
  void initState() {
    super.initState();
    futureDeterminePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _TopBar(widget._barTitle, widget._localLoyalityData,
          _ChangeSelectedLocalLoyalityData),
      backgroundColor: Color.fromARGB(58, 158, 158, 158),
      body: _PageContent(
        widget._SelectedLocalLotalityData,
        widget._localLoyaltyLocationData,
        widget._recommendatedBusinessIds,
        widget._recommendationReasons,
        _UpdateAfterNiButtonClicked,
      ),
    );
  }
}

class _TopBar extends StatefulWidget implements PreferredSizeWidget {
  final _text;
  final List<LocalLoyalty> _localLoyalityData;
  Function(List<LocalLoyalty>) _ChangeSelectedLocalLoyalityData;

  _TopBar(this._text, this._localLoyalityData,
      this._ChangeSelectedLocalLoyalityData);

  @override
  State<_TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _TopBarState extends State<_TopBar> {
  final List<String> _categories = [
    'Food & Drink',
    'Education',
    'Automotive',
    'Entertainment',
    'Health',
    'Home Improvement'
  ];
  final List<bool> _categoriesSelected = [
    false,
    false,
    false,
    false,
    false,
    false
  ];
  final List<IconData> _categoriesIcons = [
    Icons.fastfood,
    Icons.cast_for_education,
    Icons.directions_car,
    Icons.movie_sharp,
    Icons.health_and_safety,
    Icons.home
  ];

  final List<String> _sortingOptions = ["Near me", "Alphabet"];
  final List<bool> _sortingOptionsSelected = [false, false];
  final List<IconData> _sortingOptionIcons = [
    Icons.location_on,
    Icons.sort_by_alpha
  ];

  /// Builder for the local loyalty page that allows for different types of sorting and updates the page accordingly
  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: <Widget>[
        IconButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                backgroundColor: Colors.transparent,
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.97),
                builder: (BuildContext context) {
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Container(
                      height: 210,
                      width: 370,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Container(
                            height: 210,
                            width: 370,
                            decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(15),
                                  topRight: const Radius.circular(15),
                                  bottomLeft: const Radius.circular(15),
                                  bottomRight: const Radius.circular(15),
                                )),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(" Filter Local Loyalty discounts: ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: msufcuForestGreen)),
                                SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (int i = 0;
                                              i < _categories.length;
                                              i++)
                                            FilterChip(
                                              showCheckmark: false,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                side: BorderSide(
                                                  color: msufcuForestGreen,
                                                ),
                                              ),
                                              selected: _categoriesSelected[i],
                                              label: Text(_categories[i],
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                              avatar: Icon(_categoriesIcons[i]),
                                              elevation: 10,
                                              pressElevation: 5,
                                              shadowColor: Colors.teal,
                                              backgroundColor:
                                                  Colors.transparent,
                                              selectedColor: msufcuForestGreen,
                                              onSelected: (bool selected) {
                                                setState(() {
                                                  _categoriesSelected[i] =
                                                      selected;
                                                  UpdateSelectedLocalLoyalityData(
                                                      widget._localLoyalityData,
                                                      _categories,
                                                      _categoriesSelected,
                                                      widget
                                                          ._ChangeSelectedLocalLoyalityData,
                                                      _sortingOptions,
                                                      _sortingOptionsSelected);
                                                });
                                              },
                                            ),
                                        ])),
                                Text(" Sort By: ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: msufcuForestGreen)),
                                SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (int i = 0;
                                              i < _sortingOptions.length;
                                              i++)
                                            ChoiceChip(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                side: BorderSide(
                                                  color: msufcuForestGreen,
                                                ),
                                              ),
                                              selected:
                                                  _sortingOptionsSelected[i],
                                              label: Text(_sortingOptions[i],
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                              avatar:
                                                  Icon(_sortingOptionIcons[i]),
                                              elevation: 10,
                                              pressElevation: 5,
                                              shadowColor: Colors.teal,
                                              backgroundColor:
                                                  Colors.transparent,
                                              selectedColor: msufcuForestGreen,
                                              onSelected: (bool selected) {
                                                setState(() {
                                                  _sortingOptionsSelected[i] =
                                                      selected;
                                                  if (selected) {
                                                    for (int j = 0;
                                                        j <
                                                            _sortingOptionsSelected
                                                                .length;
                                                        j++) {
                                                      if (i != j) {
                                                        if (_sortingOptionsSelected[
                                                            j]) {
                                                          _sortingOptionsSelected[
                                                              j] = false;
                                                        }
                                                      }
                                                    }
                                                  }
                                                  UpdateSelectedLocalLoyalityData(
                                                      widget._localLoyalityData,
                                                      _categories,
                                                      _categoriesSelected,
                                                      widget
                                                          ._ChangeSelectedLocalLoyalityData,
                                                      _sortingOptions,
                                                      _sortingOptionsSelected);
                                                });
                                              },
                                            ),
                                        ])),
                                Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height: 45,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          for (int i = 0;
                                              i < _categoriesSelected.length;
                                              i++) {
                                            _categoriesSelected[i] = false;
                                          }
                                          for (int i = 0;
                                              i <
                                                  _sortingOptionsSelected
                                                      .length;
                                              i++) {
                                            _sortingOptionsSelected[i] = false;
                                          }
                                          UpdateSelectedLocalLoyalityData(
                                              widget._localLoyalityData,
                                              _categories,
                                              _categoriesSelected,
                                              widget
                                                  ._ChangeSelectedLocalLoyalityData,
                                              _sortingOptions,
                                              _sortingOptionsSelected);
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        "CLEAR",
                                        style: TextStyle(
                                          color: msufcuForestGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    );
                  });
                },
              );
            },
            icon: Icon(
              Icons.filter_alt,
              size: 30.0,
              color: Colors.black,
            ))
      ],
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: BackButton(
          onPressed: () => {
                widget._ChangeSelectedLocalLoyalityData(
                    widget._localLoyalityData),
                Navigator.pop(context)
              }),
      title: const Text("Local Loyalty",
          style: TextStyle(
            fontSize: 25,
            color: msufcuForestGreen,
          )),
      centerTitle: true,
    );
  }
}

class _PageContent extends StatefulWidget {
  final List<LocalLoyalty> _SelectedLocalLotalityData;
  final List<LocalLoyaltyLocation> _localLoyaltyLocationData;
  final List<String> _recommendatedBusinessIds;
  final Map<String, String> _recommendationReasons;
  final Function _UpdateAfterNiButtonClicked;
  const _PageContent(
      this._SelectedLocalLotalityData,
      this._localLoyaltyLocationData,
      this._recommendatedBusinessIds,
      this._recommendationReasons,
      this._UpdateAfterNiButtonClicked);

  @override
  State<_PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<_PageContent> {
  bool _sortedByLocation = false;

  void changeSortingStatus() {
    setState(() {
      if (_sortedByLocation) {
        _sortedByLocation = false;
      } else {
        _sortedByLocation = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
        future: getAllDiscountDetails(
            widget._SelectedLocalLotalityData,
            _sortedByLocation,
            widget._localLoyaltyLocationData,
            widget._recommendatedBusinessIds,
            widget._recommendationReasons,
            widget._UpdateAfterNiButtonClicked),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(children: [
                  Center(child: snapshot.data),
                ]));
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return Container(
                color: Color.fromARGB(58, 158, 158, 158),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.height * 0.2,
                    child: CircularProgressIndicator(
                      strokeWidth: 15,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(msufcuBrightGreen),
                      semanticsLabel: 'Circular progress indicator',
                    )));
          }
        });
  }
}

class _contentArea extends StatelessWidget {
  final _titleText;
  final _discountContent;
  final _imageLink;
  final _id;
  final _isRecommended;
  final _recommendationReasons;
  final _location;
  final Function _UpdateAfterNiButtonClicked;

  const _contentArea(
      this._titleText,
      this._discountContent,
      this._imageLink,
      this._id,
      this._isRecommended,
      this._recommendationReasons,
      this._location,
      this._UpdateAfterNiButtonClicked);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.3,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      color: Colors.white,
      child: Column(children: [
        _disountTitle(
            _titleText,
            _discountContent,
            _imageLink,
            _id,
            _isRecommended,
            _recommendationReasons,
            _UpdateAfterNiButtonClicked),
        _discountDetail(
            _titleText,
            _discountContent,
            _imageLink,
            _id,
            _isRecommended,
            _location,
            _recommendationReasons,
            _UpdateAfterNiButtonClicked),
      ]),
    );
  }
}

class _disountTitle extends StatelessWidget {
  final _title;
  final _discountContent;
  final _imageLink;
  final _id;
  final _isRecommended;
  final _recommendationReasons;
  final Function _UpdateAfterNiButtonClicked;
  const _disountTitle(
      this._title,
      this._discountContent,
      this._imageLink,
      this._id,
      this._isRecommended,
      this._recommendationReasons,
      this._UpdateAfterNiButtonClicked);

  Container _titleSection(bool _isRecommended, BuildContext context) {
    if (_isRecommended) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.07,
        child: Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            child: Image(image: AssetImage('images/thumbs-up.png')),
            onTap: () {
              String recommendationRason = "";
              if (_recommendationReasons[_id] != null) {
                recommendationRason = _recommendationReasons[_id];
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => IconDetail(
                        _title,
                        _imageLink,
                        _discountContent,
                        recommendationRason,
                        _id,
                        _UpdateAfterNiButtonClicked)),
              );
            },
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Container _titleText(context) {
    if (_title.length > 23 && _isRecommended) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.07,
        child: Center(
          child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                _title.substring(0, 23) + "...",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 20),
              )),
        ),
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.07,
        child: Center(
          child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                _title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 20),
              )),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.07,
        color: msufcuForestGreen,
      ),
      _titleText(context),
      _titleSection(_isRecommended, context)
    ]);
  }
}

void temp() {}

class _discountDetail extends StatelessWidget {
  final String _titleText;
  final String _discountContent;
  final String _imageLink;
  final String _id;
  final bool _isRecommended;
  final LocalLoyaltyLocation _location;
  final _recommendationReasons;
  final Function _UpdateAfterNiButtonClicked;
  const _discountDetail(
      this._titleText,
      this._discountContent,
      this._imageLink,
      this._id,
      this._isRecommended,
      this._location,
      this._recommendationReasons,
      this._UpdateAfterNiButtonClicked);

  Widget _textDisplay(context) {
    String recommendationReason = "";
    if (_recommendationReasons[_id] != null) {
      recommendationReason = _recommendationReasons[_id];
    }

    if (_discountContent.length < 150) {
      return Text(_discountContent);
    } else {
      return RichText(
        text: TextSpan(
          text: _discountContent.substring(0, 135),
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
                text: ' ...read more',
                style: TextStyle(fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => IconDetail(
                                  _titleText,
                                  _imageLink,
                                  _discountContent,
                                  recommendationReason,
                                  _id,
                                  _UpdateAfterNiButtonClicked)),
                        )
                      }),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Row(
        children: [
          FadeInImage(
            width: MediaQuery.of(context).size.width * 0.35,
            height: MediaQuery.of(context).size.height * 0.23,
            image: NetworkImage(_imageLink),
            fit: BoxFit.fill,
            placeholder: AssetImage(
              "./images/placeholder.svg.png",
            ),
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset('./images/placeholder.svg.png',
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.height * 0.23,
                  fit: BoxFit.fill);
            },
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.2,
            child: _textDisplay(context),
          ),
        ],
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.225,
          child: Align(
            alignment: Alignment(0.92, 1),
            child: RichText(
              text: TextSpan(
                  text:
                      "${(businessToPhone[_id]! / 1609.344).toStringAsFixed(1)} Miles away >",
                  style: TextStyle(color: msufcuForestGreen, fontSize: 15),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => {
                          MapsLauncher.launchCoordinates(
                              double.parse(_location.m_latitude),
                              double.parse(_location.m_longitude),
                              _titleText)
                        }),
            ),
          ))
    ]);
  }
}

/// Custom sorting function that sorts by distance
int sortByDistance(LocalLoyalty a, LocalLoyalty b) {
  //check if keys exist in the map
  if (((businessToPhone.containsKey(a.m_id))) &&
      (businessToPhone.containsKey(b.m_id))) {
    if (businessToPhone[a.m_id]! > businessToPhone[b.m_id]!) {
      return 1;
    } else {
      return -1;
    }
  }
  //if one key exists and the other doesn't then perform these:
  if (businessToPhone.containsKey(a.m_id)) {
    return 1;
  } else if (businessToPhone.containsKey(b.m_id)) {
    return -1;
  } else {
    return 0;
  }
}

/// Creates a sorted map of the closes local loyalty businesses
LocalLoyaltyLocation getLocation(
    List<LocalLoyaltyLocation> localLoyaltyLocation,
    List<LocalLoyalty> dicountDetails,
    String id) {
  var distanceFromPhone = {};
  for (var i = 0; i < dicountDetails.length; i++) {
    distanceFromPhone[dicountDetails[i].m_id] = 0;
  }
  double shortest_distance = 0;
  late LocalLoyaltyLocation shortestLocalLoyaltyLocationObject;
  for (var i = 0; i < localLoyaltyLocation.length; i++) {
    if (distanceFromPhone.containsKey(localLoyaltyLocation[i].m_id)) {
      //calculate distance from phone to business location
      var distance = Geolocator.distanceBetween(
          _phonePosition.latitude,
          _phonePosition.longitude,
          double.parse(localLoyaltyLocation[i].m_latitude),
          double.parse(localLoyaltyLocation[i].m_longitude));

      if (localLoyaltyLocation[i].m_id == id && shortest_distance == 0) {
        shortest_distance = distance;
        shortestLocalLoyaltyLocationObject = localLoyaltyLocation[i];
      } else if (localLoyaltyLocation[i].m_id == id &&
          distance < shortest_distance) {
        shortest_distance = distance;
        shortestLocalLoyaltyLocationObject = localLoyaltyLocation[i];
      }
    }
  }
  return shortestLocalLoyaltyLocationObject;
}

// Gets all the local loyalty data for each business
Future<Widget> getAllDiscountDetails(
    List<LocalLoyalty> dicountDetails,
    bool sortedByLocation,
    List<LocalLoyaltyLocation> _localLoyaltyLocation,
    List<String> _recommendatedBusinessIds,
    Map<String, String> _recommendationReasons,
    Function _UpdateAfterNiButtonClicked) async {
  /// Loading time long because await called every time button is clicked,
  /// find place ot put these functions where its not called as much
  Position _position = await _determinePosition();
  _phonePosition = await _determinePosition();
  List<Widget> list = [];
  if (sortedByLocation) {
    List<LocalLoyalty> cloneddicountDetails = [...dicountDetails];
    var distanceFromPhone = {};
    for (var i = 0; i < cloneddicountDetails.length; i++) {
      distanceFromPhone[cloneddicountDetails[i].m_id] = 0;
    }

    //calculates distance from each business to the phone and stores in a dict
    for (var i = 0; i < _localLoyaltyLocation.length; i++) {
      if (distanceFromPhone.containsKey(_localLoyaltyLocation[i].m_id)) {
        //calculate distance from phone to business location
        var distance = Geolocator.distanceBetween(
            _position.latitude,
            _position.longitude,
            double.parse(_localLoyaltyLocation[i].m_latitude),
            double.parse(_localLoyaltyLocation[i].m_longitude));

        if (businessToPhone[_localLoyaltyLocation[i].m_id] == null) {
          businessToPhone[_localLoyaltyLocation[i].m_id] = distance;
        } else if (businessToPhone[_localLoyaltyLocation[i].m_id] != null &&
            businessToPhone[_localLoyaltyLocation[i].m_id]! > distance) {
          businessToPhone[_localLoyaltyLocation[i].m_id] = distance;
        }
      }
    }
    cloneddicountDetails.sort(sortByDistance);
    for (var i = 0; i < cloneddicountDetails.length; i++) {
      bool isRecommendated =
          _recommendatedBusinessIds.contains(cloneddicountDetails[i].m_id);
      list.add(_contentArea(
        cloneddicountDetails[i].m_name,
        cloneddicountDetails[i].m_discount,
        cloneddicountDetails[i].m_image_url,
        cloneddicountDetails[i].m_id,
        isRecommendated,
        _recommendationReasons,
        getLocation(_localLoyaltyLocation, dicountDetails,
            cloneddicountDetails[i].m_id),
        _UpdateAfterNiButtonClicked,
      ));
    }
  } else {
    for (var i = 0; i < dicountDetails.length; i++) {
      bool isRecommendated =
          _recommendatedBusinessIds.contains(dicountDetails[i].m_id);
      list.add(_contentArea(
          dicountDetails[i].m_name,
          dicountDetails[i].m_discount,
          dicountDetails[i].m_image_url,
          dicountDetails[i].m_id,
          isRecommendated,
          _recommendationReasons,
          getLocation(
              _localLoyaltyLocation, dicountDetails, dicountDetails[i].m_id),
          _UpdateAfterNiButtonClicked));
    }
  }
  return Column(children: list);
}

/// Gets the distance from the phones current location and the businesses
Future<void> GetDistanceBetweenPhoneAndBusiness(
    List<LocalLoyalty> dicountDetails,
    List<LocalLoyaltyLocation> localLoyaltyLocation) async {
  Position _position = await _determinePosition();

  var distanceFromPhone = {};
  for (var i = 0; i < dicountDetails.length; i++) {
    distanceFromPhone[dicountDetails[i].m_id] = 0;
  }

  for (var i = 0; i < localLoyaltyLocation.length; i++) {
    if (distanceFromPhone.containsKey(localLoyaltyLocation[i].m_id)) {
      //calculate distance from phone to business location
      var distance = Geolocator.distanceBetween(
          _position.latitude,
          _position.longitude,
          double.parse(localLoyaltyLocation[i].m_latitude),
          double.parse(localLoyaltyLocation[i].m_longitude));
      if (businessToPhone[localLoyaltyLocation[i].m_id] == null) {
        businessToPhone[localLoyaltyLocation[i].m_id] = distance;
      } else if (businessToPhone[localLoyaltyLocation[i].m_id] != null &&
          businessToPhone[localLoyaltyLocation[i].m_id]! > distance) {
        businessToPhone[localLoyaltyLocation[i].m_id] = distance;
      }
    }
  }
}

/// Updates the sorting of the local loyalty data
void UpdateSelectedLocalLoyalityData(
    List<LocalLoyalty> localLoyalityData,
    List<String> categories,
    List<bool> categoriesSelected,
    Function(List<LocalLoyalty>) CallBackFunction,
    List<String> sortingOptions,
    List<bool> sortingOptionsSelected) {
  // Get the name of all the selected categories in a list
  List<String> selectedCategories = [];
  for (int i = 0; i < categoriesSelected.length; i++) {
    if (categoriesSelected[i]) {
      selectedCategories.add(categories[i]);
    }
  }
  // Get the name of the selected sorting option
  String selectedSortingOption = "";
  for (int i = 0; i < sortingOptions.length; i++) {
    if (sortingOptionsSelected[i]) {
      selectedSortingOption = sortingOptions[i];
      break;
    }
  }
  // If no category option and no sorting option are selected, just display the data in default order
  if (selectedCategories.isEmpty && selectedSortingOption == "") {
    CallBackFunction(localLoyalityData);
    return;
  }

  // Get the data for selected categories
  List<LocalLoyalty> newSelectedLocalLotalityData = [];
  if (selectedCategories.isEmpty) {
    newSelectedLocalLotalityData = [...localLoyalityData];
  } else {
    for (int i = 0; i < localLoyalityData.length; i++) {
      if (selectedCategories.contains(localLoyalityData[i].m_category_main)) {
        newSelectedLocalLotalityData.add(localLoyalityData[i]);
      }
    }
  }

  // Sort by seelceted sorting option
  if (selectedSortingOption == sortingOptions[0]) {
    newSelectedLocalLotalityData.sort(
        (a, b) => businessToPhone[a.m_id]!.compareTo(businessToPhone[b.m_id]!));
  } else if (selectedSortingOption == sortingOptions[1]) {
    newSelectedLocalLotalityData.sort((a, b) => a.m_name.compareTo(b.m_name));
  }

  // This function will call function _ChangeSelectedLocalLoyalityData in class _LocalLoyaltyDetailsState
  //  and update the SelectedLocalLotalityData and update the screen.
  CallBackFunction(newSelectedLocalLotalityData);
}
