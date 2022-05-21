import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyNotification {
  static Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  }

  static Future<void> scheduleNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      RestorableDateTime dt,
      String payload) async {
    int seconds = dt.value.difference(DateTime.now()).inSeconds;
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Reminder',
        payload,
        tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'full screen channel id', 'full screen channel name',
                channelDescription: 'full screen channel description',
                priority: Priority.high,
                importance: Importance.high,
                fullScreenIntent: true)),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}
