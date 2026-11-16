

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

typedef AccessTokenProvider = Future<String?> Function();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}, data=${message.data}');
}

class PushNotificationService {
  final FirebaseMessaging messaging;
  final AccessTokenProvider getAccessToken;
  final Future<void> Function(String) registerDeviceToken;
  final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();
  PushNotificationService({
    required AccessTokenProvider getAccessToken,
    required Future<void> Function(String) registerDeviceToken,
    FirebaseMessaging? messaging,
  }) : getAccessToken = getAccessToken,
        registerDeviceToken = registerDeviceToken,
        messaging = messaging ?? FirebaseMessaging.instance;
  Future<void> initialize() async {
    await initializeLocalNotifications();
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(handleForegroundMessage);

    messaging.onTokenRefresh.listen((token) async {
      try {
        await registerIfAuthenticated(token);
      } catch (error, stackTrace) {
        debugPrint('FCM token registration failed: $error');
        debugPrint('$stackTrace');
      }
    });
  }

  Future<void> initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_stat_notification',
    );

    const initializationSwttings = InitializationSettings(
      android: androidSettings,
    );
    await localNotifications.initialize(initializationSwttings, onDidReceiveNotificationResponse: handleLocalNotificationTap,);
    const channel = AndroidNotificationChannel(
      'default_notifications',
      'Default notifications',
      description: 'Application notifications',
      importance: Importance.high,
    );
    await localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  void handleLocalNotificationTap(NotificationResponse notificationResponse) {
    debugPrint('Notification tapped: $notificationResponse');
    final payload = notificationResponse.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload);
      if (data is Map) {
        _localNotificationTaps.add(Map<String, dynamic>.from(data),);
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to parse notification payload: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> handleForegroundMessage(RemoteMessage message) async {

    final title = message.notification?.title ?? message.data['title']?.toString() ?? 'Digital Graffiti';
    final body = message.notification?.body ?? message.data['body']?.toString() ?? 'New notification';
    debugPrint(
      'Foreground FCM message: '
          'title=$title'
          'body=$body'
          'data=${message.data}',
    );
    await localNotifications.show(message.hashCode,
    title, body, const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_notifications',
            'Default notifications',
            channelDescription: 'Application notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      payload: jsonEncode(message.data),
    );
  }
  final StreamController<Map<String,dynamic>> _localNotificationTaps = StreamController<Map<String,dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get localNotificationTaps => _localNotificationTaps.stream;
  Stream<RemoteMessage> get foregroundMessages =>
      FirebaseMessaging.onMessage;
  Stream<RemoteMessage> get openedMessages =>
      FirebaseMessaging.onMessageOpenedApp;
  Future<RemoteMessage?> get initialMessage =>
      messaging.getInitialMessage();
  Future<void> registerCurrentToken() async {
    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await registerIfAuthenticated(token);
    }
  }
  Future<void> registerIfAuthenticated(String token) async {
    final accessToken = await getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }
    await registerDeviceToken(token);
  }
  void dispose() {
    _localNotificationTaps.close();
  }
}