import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:projectkiaforest/produitDB.dart';
class Notifications {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    var initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSFlutterLocalNotificationsPlugin();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        //iOS: initializationSettingsIOS);
        );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> sendNotification(
      String title, String message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_id', 'Product Notification',
        importance: Importance.max, priority: Priority.high);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: null);
    await flutterLocalNotificationsPlugin.show(
        0, title, message, platformChannelSpecifics);
  }
}
