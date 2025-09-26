import 'dart:io';
import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:letsshop/user_panel/notification_screen.dart';
import 'package:letsshop/utils/app_constants.dart';

class NotificationServices {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Android notification channel
  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
    'ecomm-channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
  );

  /// Request notification permissions (iOS + Android 13+)
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('ℹ️ User granted provisional permission');
    } else {
      Get.snackbar(
        'Notifications Disabled',
        'Please enable notifications in settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.AppMainColor,
        colorText: Colors.white,
      );
      Future.delayed(const Duration(seconds: 2), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  /// Get FCM device token
  Future<String> getDeviceToken() async {
    String? token = await _messaging.getToken();
    debugPrint("📱 FCM Device Token => $token");
    return token ?? '';
  }

  /// Initialize local notifications
  Future<void> initializeLocalNotifications() async {
    // Android init
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS init
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    final InitializationSettings initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    // Initialize with tap handler
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          _handleMessage(data); // handle Map<String, dynamic>
        }
      },
    );

    // Create Android channel
    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    // iOS: allow showing notifications in foreground
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Listen to foreground FCM messages
  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Foreground message: ${message.data}");
      if (message.notification != null) {
        _showNotification(message);
      }
    });
  }

  /// Show a local notification
  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification!;
    final android = notification.android;

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: android?.smallIcon ?? '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    final notifDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      notifDetails,
      payload: jsonEncode({
        'title': notification.title,
        'body': notification.body,
        ...message.data,
      }), // pass both notification + data
    );
  }

  /// Handle background & terminated notification taps
  Future<void> setUpInteractMessage(BuildContext buildContext) async {
    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📲 Notification tapped (background): ${message.data}");
      _handleMessage(message);
    });

    // Terminated tap
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
          "🚀 App opened from terminated by notification: ${initialMessage.data}");
      _handleMessage(initialMessage);
    }
  }

  /// Navigate when notification tapped
  void _handleMessage([dynamic message]) {
    RemoteMessage? remoteMessage;

    if (message is RemoteMessage) {
      remoteMessage = message;
    } else if (message is Map<String, dynamic>) {
      // Wrap map into RemoteMessage-like object
      remoteMessage = RemoteMessage(
        data: message,
        notification: RemoteNotification(
          title: message['title'] ?? 'No Title',
          body: message['body'] ?? 'No Body',
        ),
      );
    }

    if (remoteMessage != null) {
      Get.to(() => NotificationScreen(message: remoteMessage!));
    }
  }
}
