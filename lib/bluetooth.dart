// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hex/hex.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:msufcu_flutter_project/send_amount_page.dart';
import 'package:msufcu_flutter_project/widgets/interactive_button.dart';
import 'package:msufcu_flutter_project/widgets/send_money_member_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'objects/user_info.dart';
import 'sql/query.dart';

//This is the wrapper class for the actual stateful widget page
class BluetoothPage extends StatefulWidget {
  const BluetoothPage(
      {super.key, required this.loggedInUser, required this.blue});
  //Current user
  final UserInfo loggedInUser;
  //Bluetooth object
  final Bluetooth blue;
  void refresh() {}

  //Returns the currently logged in user (used in child class)
  UserInfo getLoggedInUser() {
    return loggedInUser;
  }

  //Creates a state of type (child class which updates states)
  @override
  State<BluetoothPage> createState() => BluetoothPageState();
}

/// Bluetooth state page that connects user phone to another user also on their bluetooth page
class BluetoothPageState extends State<BluetoothPage> {
  //Initial list view, used as a placeholder
  ListView listV = ListView(children: const [
    SizedBox(
      height: 50,
      child: Center(child: Text("Tap button to initiate scan.")),
    )
  ]);
  //Color used to make the animation transparent
  Color anim = const Color.fromARGB(0, 0, 0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              //Make the page go backwards
              onPressed: () => {
                Navigator.of(context).pop(),
                descriptionController.clear(),
              },
            ),
            title: const Text("Bluetooth Connection"),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black),
        resizeToAvoidBottomInset: false,
        body: Center(
            child: FractionallySizedBox(
                widthFactor: .9,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 150,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InteractiveButton(
                                  width: 175,
                                  onPressed: () async {
                                    //When pressed, set the animation as turned on
                                    setState(() {
                                      anim = Colors.black;
                                    });
                                    //Create an advertisement to advertise bluetooth connection
                                    Advertise advert = Advertise(
                                        widget.loggedInUser.m_username);
                                    //Enable advertisement
                                    advert.doAdvertise();
                                    //Scan for devices
                                    await widget.blue.scanForDevices();
                                    //Update the found members list
                                    ListView updatedList =
                                        await widget.blue.getFoundMembers();
                                    //Set the state and change the list, turn the animation off
                                    setState(() {
                                      listV = updatedList;
                                      anim = const Color.fromARGB(0, 0, 0, 0);
                                    });
                                    //Stop advertising
                                    advert.stopAdvertise();
                                  },
                                  title: 'Bluetooth',
                                ),
                                const SizedBox(width: 20),
                                LoadingAnimationWidget.staggeredDotsWave(
                                  color: anim,
                                  size: 40,
                                )
                              ])),
                      SizedBox(height: 250, child: listV),
                    ]))));
  }
}

//Bluetooth class that performs the backend connections
class Bluetooth {
  //Currently logged in user who's using the app
  final UserInfo loggedInUser;
  //List of users that have been found after scan
  List<String> foundUsers = [];
  //On startup, request permission
  Bluetooth(this.loggedInUser) {
    requestPermissions();
  }

  // gets permissions for bluetooth use on device if unselected
  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise
    ].request();
  }

  // function that scans for other user devices
  Future<void> scanForDevices() async {
    //Create an instance of the flutterblue package
    FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
    //Initialize scan results
    List<ScanResult> scans = [];
    //Perform a scan for devices
    flutterBlue.scan(timeout: const Duration(seconds: 15)).listen((scanResult) {
      //For everything that is found, even non-members, add it to a list to be parsed
      scans.add(scanResult);
    });
    //If you don't wait, then the scan will stop instantly, so a timer is set to give the scan duration
    await Future.delayed(const Duration(seconds: 6));
    //Stop the scan after the timer is up
    flutterBlue.stopScan();
    //Initialize the scan list
    foundUsers.clear();
    for (ScanResult result in scans) {
      //If there's a UUID
      if (result.advertisementData.serviceUuids.isNotEmpty) {
        //Parse the UUID
        String uuid =
            result.advertisementData.serviceUuids.first.replaceAll("-", "");
        //Decode the UUID hex value
        List<int> hexData = HEX.decode(uuid);
        //Turn the ints into ascii characters
        String username = stringFromAscii(hexData);
        //If the unique identifier is found in the UUID, then add the corresponding user
        if (username.isNotEmpty && username.contains("msufcu")) {
          foundUsers.add(username);
        }
      }
    }
  }

  // Takes a list of ints and converts that list into a string, with each character being a char entry in the list
  String stringFromAscii(List<int> input) {
    String returnValue = "";
    int index = 0;
    for (int i in input) {
      returnValue += String.fromCharCode(i);
      if (index == 5) {
        returnValue += "-";
      }
      index++;
    }
    return returnValue;
  }

  ///Function that returns the users found when bluetooth button is pressed
  Future<ListView> getFoundMembers() async {
    //If no users are found, return an empty list
    if (foundUsers.isEmpty) {
      return ListView(children: const <Widget>[
        SizedBox(
          height: 50,
          child: Center(child: Text('No users found.')),
        )
      ]);
    }
    //Otherwise, if users are found
    else {
      //Display that users are found
      List<Widget> users = [
        const SizedBox(
          height: 50,
          child: Center(child: Text('Users found!')),
        )
      ];
      //Iterate over every found user
      for (String user in foundUsers) {
        //If the user isn't empty
        if (user.isNotEmpty) {
          //Remove the unique identifiers, leaving only the username
          user = user.replaceAll("msufcu-", "");
          //Query the database for that user, see if they exist
          Query query = Query();
          List<UserInfo> displayUser = await query.userInfoQuery(
              "*", "user_info", true, "Username='$user'");
          //Add the user to the list of users, in the form of a clickable button
          users.add(BluetoothMemberCard(
            user: displayUser[0],
            loggedInUser: loggedInUser,
          ));
        }
      }
      return ListView(children: users);
    }
  }
}

// Class that advertises a unique identifier over BLE frequency with the username of the logged in user
class Advertise {
  //On construct, take in a user
  Advertise(String user) {
    //Request permissions
    requestPermissions();
    //Assign the user
    username = user;
  }

  String username = "";
  //This is the unique identifier, spelling out "msufcu" in ascii
  List<int> msufcuID = [109, 115, 117, 102, 99, 117];
  //https://pub.dev/packages/flutter_ble_peripheral/example
  FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();

/*The logic behind advertising this way is that by using a BLE frequency where you advertise a UUID, 
you can encode the username and a unique identifier in a hexcode, and then share that advertisement without having to make 2 
devices physically connect to each other over bluetooth. Rather, you can simple use a call-and-response type 
identification in short bursts.
Then, other devices can scan and see if the advertised code corresponds to the identifier, and extract
the data encoded. There is limited space in a UUID though, which is made up of 32 hex codes, which limits the length of usernames.
Example UUID: 123e4567-e89b-12d3-a456-426614174000
*/

  //Get a UUID to advertise based on a hex value
  String getUUID(String hex) {
    String cleansedHex = hex;
    //Check to ensure that everything is encoded properly
    if (hex.length > 32) {
      throw Exception("hex is too long");
    } else if (hex.length < 32) {
      //Assuming a valid hex length, figure out if anything needs to be appended to make it 32 codes long.
      int toAppend = 32 - hex.length;
      while (toAppend > 0) {
        cleansedHex += "0";
        toAppend--;
      }
    }
    //Turn the cleansed string into a char array
    List<String> charArray = [];
    for (int i = 0; i < 32; i++) {
      charArray.add(cleansedHex[i]);
    }
    //A UUID is split up into 4 parts by hypens, so insert hyphens where they should match up.
    charArray.insert(8, "-");
    charArray.insert(13, "-");
    charArray.insert(18, "-");
    charArray.insert(23, "-");

    //Turn everything back into a string
    String finalHex = "";
    for (String s in charArray) {
      finalHex += s;
    }
    //Return the string
    return finalHex;
  }

  //Parse out char codes into a list from a given string, used as a helper function
  List<int> asciiFromString(String input) {
    List<int> ascii = msufcuID;
    for (int c = 0; c < input.length; c++) {
      ascii.add(input.codeUnitAt(c));
    }
    return ascii;
  }

  //Request permissions from manifest
  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise
    ].request();
  }

  //Perform the advertisement
  void doAdvertise() async {
    //Grab an ascii list from the logged in user's username
    List<int> ascii = asciiFromString(username);
    //Encode the ascii string into a hex code string
    String userHex = HEX.encode(ascii);
    //Get a UUID from a hex code string
    String userUUID = getUUID(userHex);
    //Create an advertisement object using the UUID
    AdvertiseData advertiseData = AdvertiseData(
      serviceUuid: userUUID,
    );
    //Specify advertising settings
    AdvertiseSettings advertiseSettings = AdvertiseSettings(
      advertiseMode: AdvertiseMode.advertiseModeBalanced,
      txPowerLevel: AdvertiseTxPower.advertiseTxPowerMedium,
      timeout: 10000,
    );
    //Advertise
    await blePeripheral.start(
        advertiseData: advertiseData, advertiseSettings: advertiseSettings);
  }

  //Stop the advertisement
  void stopAdvertise() {
    blePeripheral.stop();
  }
}

/// Creates a card with a member's name, username, and a favorites button
class BluetoothMemberCard extends StatefulWidget {
  const BluetoothMemberCard(
      {super.key, required this.user, required this.loggedInUser});

  final UserInfo user;
  final UserInfo loggedInUser;

  @override
  State<BluetoothMemberCard> createState() => _BluetoothMemberCardState();
}

// Allows for members to be selected with a tap of their card
class _BluetoothMemberCardState extends State<BluetoothMemberCard> {
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
                  fromScan: true,
                );
              })),
            },
        child: MemberCardWithoutFavorite(user: widget.user));
  }
}
