import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/currency_formatter.dart';

/// Service handling local notifications for 80% and 100% budget threshold alerts.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
    _isInitialized = true;
  }

  /// Request runtime permissions on Android 13+ (API 33+)
  Future<bool> requestPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Trigger 80% warning notification
  Future<void> showBudgetWarningNotification({
    required double spent,
    required double budget,
    required int percentage,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'kharchabook_budget_alerts',
      'KharchaBook Budget Alerts',
      channelDescription: 'Notifications for student budget limits and warnings',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: 80,
      title: '⚠️ Budget Alert: $percentage% Spent',
      body: 'You have spent ${CurrencyFormatter.format(spent)} out of your ${CurrencyFormatter.format(budget)} monthly limit.',
      notificationDetails: notificationDetails,
    );
  }

  /// Trigger 100% budget exceeded notification
  Future<void> showBudgetExceededNotification({
    required double spent,
    required double budget,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'kharchabook_budget_alerts',
      'KharchaBook Budget Alerts',
      channelDescription: 'Notifications for student budget limits and warnings',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: 100,
      title: '🚨 Budget Exceeded!',
      body: 'You have crossed your monthly budget limit of ${CurrencyFormatter.format(budget)}! Total spent: ${CurrencyFormatter.format(spent)}.',
      notificationDetails: notificationDetails,
    );
  }
}
