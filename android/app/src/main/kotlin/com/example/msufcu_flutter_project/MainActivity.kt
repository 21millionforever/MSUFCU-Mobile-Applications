package com.example.msufcu_flutter_project

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    /// Name of method channel to call Native Kotlin methods from Flutter
    private val CHANNEL = "msufcu.digital_transformation_of_member_data/pushNotifications"

    /// ID of Notification Channel
    private val CHANNEL_ID = "Push Notification Channel ID"

    /// Configures the Flutter engine to allow for communication
    /// between Flutter and Native Kotlin code
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "sendPushNotification") {
                @Suppress("UNCHECKED_CAST")
                result.success(sendPushNotification(call.arguments as List<String>))
            }
            else if (call.method == "createNotificationChannel") {
                createNotificationChannel()
            }
        }
    }

    /// Sends a push notification with the title and description created in the Flutter application
    private fun sendPushNotification(notificationData : List<String>) : Int {
        val notificationID = (System.currentTimeMillis() % Int.MAX_VALUE).toInt()
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.msufcu_logo_icon)
            .setLargeIcon(Bitmap.createScaledBitmap(BitmapFactory.decodeResource(resources, R.drawable.msufcu_logo), 128, 128, false))
            .setContentTitle(notificationData[0])
            .setContentText(notificationData[1])
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)

        with(NotificationManagerCompat.from(this)) {
            // notificationId is a unique int for each notification that you must define
            notify(notificationID, builder.build())
        }

        return notificationID
    }

    /// Creates a notification channel to send push notifications through
    private fun createNotificationChannel() {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = getString(R.string.notification_channel_name)
            val descriptionText = getString(R.string.notification_channel_description)
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            // Register the channel with the system
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
