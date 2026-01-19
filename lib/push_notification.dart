import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:permission_handler/permission_handler.dart';

import 'firebase/firebase_options.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> notificationSetup() async {
  enableIOSNotifications();
  await requestNotificationPermission();
  await registerNotificationListeners();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid && defaultTargetPlatform == TargetPlatform.android) {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }
}

Future<void> registerNotificationListeners() async {

  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@drawable/ic_launcher');
  const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings();
  const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iOSSettings);
  flutterLocalNotificationsPlugin.initialize(initSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
    if (message != null) {
      debugPrint("Message is ....${message.data}");
      showNotification(message);
    }
  });
}

showNotification(RemoteMessage message) {
  final RemoteNotification? notification = message.notification;
  if (message.data.isNotEmpty) {
    // Check if the message field contains a JSON string
    String notificationBody = '';
    if (message.data['message'] != null) {
      try {
        // Try to parse the message field as JSON
        Map<String, dynamic> messageData = json.decode(message.data['message']);
        // Use notification_description if available
        if (messageData.containsKey('notification_description')) {
          notificationBody = messageData['notification_description'];
        }
        // Use message field from the nested JSON if available
        else if (messageData.containsKey('message')) {
          notificationBody = messageData['message'];
        }
        // Fallback to the original message
        else {
          notificationBody = message.data['message'];
        }
      } catch (e) {
        // If parsing fails, use the message field directly
        notificationBody = message.data['message'];
      }
    }

    if (Platform.isAndroid) {
      final AndroidNotificationChannel channel = androidNotificationChannel();
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          message.data['title'],
          notificationBody,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: message.notification?.android?.smallIcon,
            ),
          ),
          payload: json.encode(message.data));
    } else {
      const int max32BitInt = 2147483647;
      const DarwinNotificationDetails iosPlatformSpecifics = DarwinNotificationDetails(sound: 'notification_sound.wav');
      const NotificationDetails iosChannelSpecific = NotificationDetails(iOS: iosPlatformSpecifics);
      flutterLocalNotificationsPlugin.show(
        notification.hashCode % max32BitInt,
        message.data['title'],
        notificationBody,
        iosChannelSpecific,
      );
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Background Message is ....${message.data}");
  showNotification(message);
}

Future<void> enableIOSNotifications() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
}

AndroidNotificationChannel androidNotificationChannel() => const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);