import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:msufcu_flutter_project/main_screen.dart';
import 'package:msufcu_flutter_project/msufcu_color_scheme.dart';
import 'package:path_provider/path_provider.dart';
import 'Classes/push_notification.dart';
import 'sql/deletion.dart';
import 'widgets/interactive_button.dart';
import 'objects/user_info.dart';
import 'sql/authenticate.dart';

TextEditingController usernameController = TextEditingController();
TextEditingController passwordController = TextEditingController();

class InteractiveTextField extends StatelessWidget {
  const InteractiveTextField(
      {super.key,
      this.boxWidth = 250,
      this.hintText = "",
      this.obscuredText = false,
      required this.textController});

  final double boxWidth;
  final String hintText;
  final bool obscuredText;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boxWidth,
      child: TextField(
        controller: textController,
        obscureText: obscuredText,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
            hintStyle: const TextStyle(color: msufcuForestGreen),
            hintText: hintText,
            hintMaxLines: 1,
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(width: 2.0, color: msufcuForestGreen))),
      ),
    );
  }
}

class SignInBorder extends RoundedRectangleBorder
    implements MaterialStateOutlinedBorder {
  const SignInBorder();

  @override
  OutlinedBorder? resolve(Set<MaterialState> states) {
    return const RoundedRectangleBorder();
  }
}

/// Envokes calls to Swift and Kotlin methods that create notification channels
/// on iOS and Android devices respectively
void createNotificationChannel() async {
  const platform = MethodChannel(
      'msufcu.digital_transformation_of_member_data/pushNotifications');
  try {
    await platform.invokeMethod('createNotificationChannel');
  } on PlatformException {
    throw Exception("Could not start Android Notification Channel.");
  }
}

/// Syncs listener on all devices so notifications will be received
/// at the same time
void syncWithAllDevices() async {
  while (true) {
    if (DateTime.now().millisecondsSinceEpoch % 5000 == 0) {
      /// Creates a listener that checks the database every 5 seconds to see
      /// if a push notification should be sent or not
      Timer.periodic(const Duration(seconds: 5),
          ((timer) => checkDatabaseForNotificationClearance()));

      break;
    }
  }
}

/// Deletes temp directory on app startup
/// https://pub.dev/packages/path_provider
void clearTempDirectory() async {
  Directory dir = await getTemporaryDirectory();
  dir.deleteSync(recursive: true);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    createNotificationChannel();
    clearTempDirectory();
    syncWithAllDevices();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Login Page",
        home: Scaffold(
          body: Center(
              child: Builder(
                  builder: (context) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('images/msufcu-logo.png',
                              width: 300, height: 100),
                          // Username text field
                          InteractiveTextField(
                            hintText: "Username",
                            textController: usernameController,
                            obscuredText: false,
                          ),

                          // Password text field
                          InteractiveTextField(
                            hintText: "Password",
                            textController: passwordController,
                            obscuredText: true,
                          ),
                          // Sign in button
                          const SignInButton(),
                        ],
                      ))),
        ));
  }
}

class SignInButton extends StatefulWidget {
  const SignInButton({super.key});

  @override
  SignInButtonWidget createState() {
    return SignInButtonWidget();
  }
}

class SignInButtonWidget extends State<SignInButton> {
  SignInButtonWidget();
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 15),
        child: InteractiveButton(
          width: 300,
          title: "Sign In",
          onPressed: () => triggerAuth(context),
        ));
  }

  //Method for triggering the auth process on button click
  void triggerAuth(BuildContext context) async {
    Auth authorization = Auth();
    Map<bool, UserInfo> authMatch = await authorization.isMatch(
        usernameController.text, passwordController.text);
    //If credentials are valid, navigate to hello world screen
    if (authMatch.keys.first) {
      // Change page when button is clicked
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MainScreen(loggedInUser: authMatch.values.first);
      }));
    }
    //Else show it's incorrect
    else {
      //https://api.flutter.dev/flutter/material/AlertDialog-class.html
      Future<void> denyLoginRequest() async {
        return showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Login failed'),
              content: const Text(
                  'The credentials you provided are invalid,\nplease try again.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  //test
                  style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: const Color.fromARGB(255, 24, 69, 59)),
                  child: const Text('Acknowledge'),
                ),
              ],
            );
          },
        );
      }
      denyLoginRequest();
    }
  }
}

/// Button build for testing sql connection, no need to use
class SQLButton extends StatelessWidget {
  const SQLButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 15),
        child: InteractiveButton(
          width: 300,
          title: "Test Connection",
          onPressed: () => testSQLConnection(),
        ));
  }

  /// Test function to check if sql connection is working
  void testSQLConnection() async {
    Deletion delete = Deletion();
    delete.deleteInDatabase("user_info", "MemberID='99'");
  }
}
