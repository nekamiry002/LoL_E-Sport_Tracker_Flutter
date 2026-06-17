import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'lol_matches';
  static const _channelName = 'Match Alerts';

  Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: ios,
        macOS: ios,
      ),
    );
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  /// Schedules a notification 5 min before [startTime] for a match.
  Future<void> scheduleMatchStart({
    required int notifId,
    required String title,
    required String body,
    required DateTime startTime,
  }) async {
    final fireAt = tz.TZDateTime.from(
      startTime.subtract(const Duration(minutes: 5)),
      tz.local,
    );
    if (fireAt.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id: notifId,
      title: title,
      body: body,
      scheduledDate: fireAt,
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Shows an immediate notification (for match results).
  Future<void> showNow({
    required int notifId,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id: notifId,
      title: title,
      body: body,
      notificationDetails: _details(),
    );
  }

  Future<void> cancel(int notifId) => _plugin.cancel(id: notifId);
  Future<void> cancelAll() => _plugin.cancelAll();

  Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();

  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
}
