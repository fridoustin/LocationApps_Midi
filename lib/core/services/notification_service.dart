// lib/core/services/notification_service.dart

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize(ProviderContainer container) async {
    
    // Konfigurasi untuk notifikasi lokal (saat aplikasi terbuka)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null && response.payload!.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _handleNavigation(data, container);
      }
    },
  );
    
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);

    _setupHandlers(container);
  }

  // Method ini dipanggil di HomeScreen
  Future<void> requestPermissionAndGetToken() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications.');
      final fcmToken = await _firebaseMessaging.getToken();
      print("===== FCM TOKEN: $fcmToken =====");
      if (fcmToken != null) {
        await _saveTokenToDatabase(fcmToken);
      }
    } else {
      print('User declined or has not accepted notification permission.');
    }
  }

  void _setupHandlers(ProviderContainer container) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Got a message whilst in the foreground!");
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('--- NOTIFICATION TAPPED FROM BACKGROUND ---');
      print('Received data payload: ${message.data}');
      _handleNavigation(message.data, container);
    });

    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('--- NOTIFICATION TAPPED FROM TERMINATED ---');
        print('Received data payload: ${message.data}');
        _handleNavigation(message.data, container);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleNavigation(Map<String, dynamic> data, ProviderContainer container) {
    print('--- MENYIMPAN DATA NOTIFIKASI KE PROVIDER ---');
    container.read(initialNotificationProvider.notifier).state = data;
  }

  Future<void> _saveTokenToDatabase(String token) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await supabase
            .from('users')
            .update({'fcm_token': token})
            .eq('id', userId);
        print("FCM token saved successfully to Supabase.");
      } catch (e) {
        print("Error saving FCM token to Supabase: $e");
      }
    }
  }

  void _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final initialNotificationProvider = StateProvider<Map<String, dynamic>?>((ref) => null);