import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'firestore_service.dart';

part 'notification_service.g.dart';

// ── Background message handler ────────────────────────────────────────────────
// Must be a top-level function as required by firebase_messaging.

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background message: ${message.messageId}');
}

// ── Channel constants ─────────────────────────────────────────────────────────

const _channelId = 'tutorme_channel';
const _channelName = 'Tutor Me Notifications';
const _channelDesc = 'Study reminders and updates from Tutor Me';

/// Manages Firebase Cloud Messaging + flutter_local_notifications for TutorMe.
class NotificationService {
  NotificationService(this._ref);

  final Ref _ref;

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _messaging = FirebaseMessaging.instance;

  final StreamController<String?> _tapController =
      StreamController<String?>.broadcast();

  /// Stream of notification-type strings emitted when user taps a notification.
  /// Values: 'new_questions' | 'streak_reminder' | 'report_resolved' | null
  Stream<String?> get onNotificationTap => _tapController.stream;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init(String uid) async {
    tz.initializeTimeZones();

    // ── FCM permissions ──────────────────────────────────────────────────
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── Local notifications init ──────────────────────────────────────────
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // already requested via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // ── Android channel ───────────────────────────────────────────────────
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDesc,
              importance: Importance.high,
            ),
          );
    }

    // ── FCM token → Firestore ─────────────────────────────────────────────
    final token = await _messaging.getToken();
    if (token != null) {
      await _ref.read(firestoreServiceProvider).saveFcmToken(uid, token);
    }
    _messaging.onTokenRefresh.listen(
      (newToken) =>
          _ref.read(firestoreServiceProvider).saveFcmToken(uid, newToken),
    );

    // ── Message handlers ──────────────────────────────────────────────────
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
  }

  // ── Foreground display ────────────────────────────────────────────────────

  Future<void> _handleForeground(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      _details(),
      payload: message.data['type'] as String?,
    );
  }

  // ── Tap handling ──────────────────────────────────────────────────────────

  void _onNotificationTap(NotificationResponse response) {
    _tapController.add(response.payload);
  }

  void _handleTap(RemoteMessage message) {
    _tapController.add(message.data['type'] as String?);
  }

  // ── Daily Reminder ────────────────────────────────────────────────────────

  /// Schedule a repeating daily local notification at the given [time].
  Future<void> scheduleDailyReminder(DateTime time) async {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      0, // fixed id=0 for the daily reminder slot
      '📚 Time to study!',
      'Keep your streak going on Tutor Me.',
      tz.TZDateTime.from(target, tz.local),
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Required for iOS — interprets the scheduled time in wall-clock terms.
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }

  Future<void> cancelDailyReminder() => _localNotifications.cancel(0);

  /// Immediately display a local notification (for testing or report alerts).
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) =>
      _localNotifications.show(
        id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        _details(),
        payload: payload,
      );

  // ── Helpers ───────────────────────────────────────────────────────────────

  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      );

  void dispose() => _tapController.close();
}

// ── Providers ─────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  final svc = NotificationService(ref);
  ref.onDispose(svc.dispose);
  return svc;
}
