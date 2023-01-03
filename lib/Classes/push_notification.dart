import 'dart:async';

import 'package:flutter/services.dart';
import 'package:msufcu_flutter_project/my_offers_screen.dart';
import 'package:msufcu_flutter_project/sql/update.dart';

import '../sql/query.dart';

/// Create a push notification with a title and a description
class PushNotification {
  /// Title of the push notification you're sending
  String title = "";

  /// Description of the push notification you're sending
  String description = "";

  PushNotification(this.title, this.description);
}

/// This function takes a PushNotification object and calls
/// a method written in Kotlin to natively push a notification
void sendPushNotification(PushNotification notification) async {
  const platform = MethodChannel(
      'msufcu.digital_transformation_of_member_data/pushNotifications');
  try {
    /// Calls an Android method that creates a push notification
    /// and returns the notificationID that would be used for notification
    /// deletion should it be needed
    await platform.invokeMethod(
        "sendPushNotification", [notification.title, notification.description]);
  } on PlatformException {
    throw Exception("Could not send Push Notification");
  }
}

int notificationsSent = 0;

/// Checks the database to see if 'send_push' in the 'push_notification_notifier'
/// table is set to true or false. If true, it sends a push notification and then
/// sets the value to false. If false, it does not do anything.
void checkDatabaseForNotificationClearance() async {
  Query query = Query();
  Update update = Update();

  if (await query.pushNotificationDatabaseQuery()) {
    List<String> reasons = getRecommendationReasons();
    if (reasons.isNotEmpty) {
      notificationsSent++;
      PushNotification notification = PushNotification(
          "We Have A Discount For You!! 🎉", (reasons..shuffle()).first);
      if (notificationsSent == 1) {
        sendPushNotification(notification);
      }

      Future.delayed(const Duration(seconds: 5), () async {
        await update.singleUpdateInDatabase(
            "send_push", "0", "push_notification_notifier", "ID = 2");
        notificationsSent = 0;
      });
    }
  }
}
