// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Inisialisasi notifikasi
  static Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _notif.initialize(initSettings);

    _initialized = true;
  }

  /// Menampilkan notifikasi sukses
  static Future<void> showSuccessNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'payment_success',        // channel id
      'Payment Success',        // channel name
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notif.show(
      1,       // notification ID
      title,   // Judul
      body,    // Isi pesan
      details, // Gaya notifikasi
    );
  }
}
