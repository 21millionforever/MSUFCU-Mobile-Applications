import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/widgets/send_money_layout_column.dart';
import 'package:msufcu_flutter_project/member_nfc.dart';

import 'bluetooth.dart';
import 'widgets/dialog_box.dart';
import 'Classes/pair.dart';
import 'Classes/triple.dart';
import 'objects/user_info.dart';
import 'sql/query.dart';
import 'widgets/nfc_icon.dart';

/// Controller that allows for text to be pulled
/// from the searchbar
TextEditingController searchBarController = TextEditingController();

/// List of users connected to logged in user that are favorited
List<UserInfo> favoritedUsers = [];

/// Map of users connected to logged in user that are favorited
Set<String> favoritedUsersSet = {};

/// List of users connected to logged in user that are not favorited
List<UserInfo> nonfavoritedUsers = [];

List<Pair<UserInfo, int>> recentUserTimes = [];

List<UserInfo> recentUsers = [];

// ValueNotifier notifies widgets that are listening to it when
// the value of the ValueNotifier is changed
// https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html

/// Notifier of a list that is populated with all users connected to
/// current logged in user.
ValueNotifier<List<UserInfo>> displayedUsers = ValueNotifier([]);

/// Notifier of a bool that signifies if a user is currently using
/// the searchbar or not
ValueNotifier<bool> searchingUsers = ValueNotifier(false);

ValueNotifier<bool> refreshingPage = ValueNotifier(false);

/// Notifier of an int that signifies which sorting button is currently selected
ValueNotifier<int> sortType = ValueNotifier(0);

/// Sort users based on selected sort type
void sortUsers() {
  List<UserInfo> tempUsers = [];

  const Map<int, String> sortTypes = {
    0: "Favorites",
    1: "Alphabetically",
    2: "Recent"
  };
  switch (sortTypes[sortType.value]) {
    // Sort by recent
    case "Recent":
      {
        recentUserTimes.sort((a, b) => a.second.compareTo(b.second));

        for (var userPair in recentUserTimes.reversed) {
          tempUsers.add(userPair.first);
        }

        recentUsers = tempUsers;

        displayedUsers.value = tempUsers;
      }
      break;
    // Sort users alphabetically by name
    case "Alphabetically":
      {
        tempUsers.addAll(favoritedUsers);
        tempUsers.addAll(nonfavoritedUsers);
        tempUsers.sort((a, b) => a.m_full_name.compareTo(b.m_full_name));
        displayedUsers.value = tempUsers;
      }
      break;
    // Sort favorites alphabetically first, then everyone else alphabetically
    default:
      {
        favoritedUsers.sort((a, b) => a.m_full_name.compareTo(b.m_full_name));
        nonfavoritedUsers
            .sort((a, b) => a.m_full_name.compareTo(b.m_full_name));

        tempUsers.addAll(favoritedUsers);
        tempUsers.addAll(nonfavoritedUsers);
        displayedUsers.value = tempUsers;
      }
  }
}

/// Getter for ValueNotifier object to an int
ValueNotifier<int> getSortTypeNotifier() {
  return sortType;
}

/// Getter for ValueNotifier object to a bool
ValueNotifier<bool> getRefreshingPageNotifier() {
  return refreshingPage;
}

/// Getter for ValueNotifier object to a bool
ValueNotifier<bool> getSearchingUsersNotifier() {
  return searchingUsers;
}

/// Getter for map of favorited UserInfo objects
Set<String> getFavoritedUserSet() {
  return favoritedUsersSet;
}

/// Getter for ValueNotifier object to a list of UserInfo objects
ValueNotifier<List<UserInfo>> getDisplayedUsersNotifier() {
  return displayedUsers;
}

/// Getter for search bar's TextEditingController object
TextEditingController getSearchBarController() {
  return searchBarController;
}

Set<String> getConnectedMemberIds() {
  List<UserInfo> temp = [];

  temp.addAll(favoritedUsers);
  temp.addAll(nonfavoritedUsers);

  Set<String> ids = {};
  for (UserInfo user in temp) {
    ids.add(user.m_id);
  }
  return ids;
}

/// Returns a list containing connected users, their favorited status, and
/// the last time they were contacted by the logged in user
/// by querying the database
Future<List<Triple<UserInfo, String, int>>> getConnectedContacts(
    UserInfo loggedInUser) async {
  Query query = Query();

  List<
      Triple<UserInfo, String,
          int>> contacts = await query.joinedUserInfoContactQuery(
      "user_info.*, contact.favorite, contact.last_contacted",
      "user_info INNER JOIN contact on contact.connected_user = user_info.MemberID",
      true,
      "contact.id_user = '${loggedInUser.m_id}'");

  return contacts;
}

/// Returns a list of connected users and the last time they were contacted
List<Pair<UserInfo, int>> getRecentUsers(
    List<Triple<UserInfo, String, int>> contacts) {
  List<Pair<UserInfo, int>> recent = [];

  for (int i = 0; i < contacts.length; i++) {
    recent.add(Pair(contacts[i].first, contacts[i].third));
  }
  return recent;
}

/// Returns a list of favorited users connected to loggedInUser
List<UserInfo> getFavoritedUsers(
    List<Triple<UserInfo, String, int>> allContacts) {
  List<UserInfo> favorited = [];

  for (var contact in allContacts) {
    if (contact.second == '1') {
      favorited.add(contact.first);
    }
  }

  return favorited;
}

// Returns a list of nonfavorited users connected to loggedInUser
List<UserInfo> getNonfavoritedUsers(
    List<Triple<UserInfo, String, int>> allContacts) {
  List<UserInfo> nonfavorited = [];

  for (var contact in allContacts) {
    if (contact.second == '0') {
      nonfavorited.add(contact.first);
    }
  }

  return nonfavorited;
}

/// Sorts favorited users alphabetically and nonfavorited users alphabetically,
/// then joins the two together to return a list containing all connected users
Future<List<UserInfo>> getConnectedUsers(UserInfo loggedInUser) async {
  List<Triple<UserInfo, String, int>> contacts =
      await getConnectedContacts(loggedInUser);

  favoritedUsers = getFavoritedUsers(contacts);
  nonfavoritedUsers = getNonfavoritedUsers(contacts);
  recentUserTimes = getRecentUsers(contacts);

  favoritedUsersSet.clear();
  for (UserInfo user in favoritedUsers) {
    favoritedUsersSet.add(user.m_id);
  }
  sortUsers();

  List<UserInfo> sortedUsers = [];

  sortedUsers = displayedUsers.value;

  return sortedUsers;
}

// **Temp** Builds the section to enable or disable NFC transfers
class NFC extends StatelessWidget {
  const NFC({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return NFCPage(loggedInUser: loggedInUser);
              }))
            },
        child: SizedBox(
            width: (MediaQuery.of(context).size.width - (40 * 3)) / 3,
            height: 80,
            child: const NFCIcon()));
  }
}

// **Temp** Builds the section to enable or disable NFC transfers
class Blue extends StatelessWidget {
  const Blue({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BluetoothPage(
                  loggedInUser: loggedInUser,
                  blue: Bluetooth(loggedInUser),
                );
              }))
            },
        child: SizedBox(
            width: (MediaQuery.of(context).size.width - (40 * 3)) / 3,
            height: 80,
            child: const Icon(size: 30, Icons.bluetooth_outlined)));
  }
}

/// Builds the page containing a searchbar, member display section,
/// QR Code button, NFC button, and filters for sorting
class SendMoney extends StatefulWidget {
  final UserInfo loggedInUser;

  const SendMoney({super.key, required this.loggedInUser});

  @override
  State<SendMoney> createState() => _SendMoneyState();
}

class _SendMoneyState extends State<SendMoney> {
  late Future<List<UserInfo>> connectedUsers;

  @override
  // Initialize variables and get data from database
  void initState() {
    super.initState();
    connectedUsers = getConnectedUsers(widget.loggedInUser);
  }

  @override
  Widget build(BuildContext context) {
    /// Creates grey display over page while data is being pulled from database,
    /// then displays member data once data is sucessfully retrieved or displays
    /// a dialog box if an error has occurred.
    return FutureBuilder<List<UserInfo>>(
        future: connectedUsers,
        builder:
            (BuildContext context, AsyncSnapshot<List<UserInfo>> snapshot) {
          // If data has been retrieved successfully,
          // display the page as normal
          if (snapshot.hasData) {
            if (!searchingUsers.value) {
              displayedUsers.value = snapshot.data as List<UserInfo>;
            }
            return Container(
                color: Colors.white,
                child: Column(children: [
                  Expanded(
                      child: SendMoneyLayoutColumn(
                          loggedInUser: widget.loggedInUser))
                ]));

            // If error has occured when getting data
            // display a dialog box notifying the user
          } else if (snapshot.hasError) {
            showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return CustomDialogBox(
                      title: "Error loading Send Money Screen",
                      content:
                          "There was an error thrown when loading this screen\n\n\nError:${snapshot.error}",
                      button: "Okay");
                });

            return SizedBox(height: MediaQuery.of(context).size.height);

            // If still waiting for the data, display normal screen
            // behind transparent, non-clickable gray widget
          } else {
            return Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    SendMoneyLayoutColumn(loggedInUser: widget.loggedInUser),
                    Container(
                        color: const Color.fromARGB(149, 82, 82, 82),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width),
                  ],
                ));
          }
        });
  }
}
