import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class LocalNotifications {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

// initialize the notification
  static Future<void> init()async {


// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();
final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
        defaultActionName: 'Open notification');
final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux);
await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // handle the notification response here
      print('Notification response received: ${response.payload}');
    });
    //  (NotificationResponse response) {},);
    print('Notification initialized successfully');

  }

//   show a simple notification
static Future<void> showSimpleNotification({
    required String title,
    required String body,
    required String payload,
}) async {
    print('Preparing to show notification: $title - $body');
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('order_updates_channel', 'Order Updates',
        channelDescription: 'Notifications for order updates',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
await flutterLocalNotificationsPlugin.show(
    0, title, body, notificationDetails,
    payload: payload);
    print('Notification shown: $title - $body');
}

}