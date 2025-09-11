// lib/core/services/notification_service.dart

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:midi_location/core/widgets/main_layout.dart';
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

  // Inisialisasi 'diam-diam', tidak meminta izin ke pengguna
  Future<void> initialize() async {
    // --- BAGIAN PERMINTAAN IZIN DAN GET TOKEN DIHAPUS DARI SINI ---
    
    // Konfigurasi untuk notifikasi lokal (saat aplikasi terbuka)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _localNotifications.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(response.payload!);
          _handleNavigation(data);
        }
      },
    );
    
    // Dengarkan jika token diperbarui (tetap di sini)
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);

    // Setup handler untuk berbagai kondisi aplikasi
    _setupHandlers();
  }

  // <<< METHOD BARU UNTUK MEMINTA IZIN DAN MENYIMPAN TOKEN >>>
  // Panggil method ini dari HomeScreen
  Future<void> requestPermissionAndGetToken() async {
    // 1. Minta izin notifikasi dari pengguna
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // 2. Jika diizinkan, ambil token dan simpan
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

  void _setupHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Got a message whilst in the foreground!");
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _handleNavigation(message.data);
    });

    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state by a notification!');
        _handleNavigation(message.data);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleNavigation(Map<String, dynamic> data) {
  //   final screen = data['screen'];
  //   final ulokId = data['ulokId'];

  //   // Pastikan navigatorKey.currentState tidak null
  //   if (navigatorKey.currentState != null && screen == '/form-kplt' && ulokId != null) {
  //     navigatorKey.currentState!.push(
  //       // PERBAIKAN: Berikan argumen yang dibutuhkan jika halaman Anda memerlukannya
  //       // Contoh: MaterialPageRoute(builder: (context) => FormKPLTPage(ulokId: ulokId)),
  //       // Untuk sekarang saya biarkan kosong sesuai kode Anda.
  //       MaterialPageRoute(builder: (context) => FormKPLTPage()),
  //     );
  //   }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    // ... (tidak ada perubahan di fungsi ini)
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
     // ... (tidak ada perubahan di fungsi ini)
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
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