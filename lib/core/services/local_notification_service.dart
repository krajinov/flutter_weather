import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();
  static const weatherAlertsPayload = 'weather-alerts';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String?> _notificationTapController =
      StreamController<String?>.broadcast();

  bool _initialized = false;

  Stream<String?> get notificationTapStream =>
      _notificationTapController.stream;

  Future<String?> initialize({bool requestPermissions = true}) async {
    if (_initialized) {
      return _launchPayload();
    }

    if (!kIsWeb) {
      tz.initializeTimeZones();
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linux = LinuxInitializationSettings(
      defaultActionName: 'Open weather alerts',
    );
    const windows = WindowsInitializationSettings(
      appName: 'Flutter Weather',
      appUserModelId: 'com.example.flutter_weather',
      guid: '1ad7f3bd-b986-4d23-a7d3-03f2ea7ad01a',
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: linux,
        windows: windows,
      ),
      onDidReceiveNotificationResponse: (response) {
        _notificationTapController.add(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackgroundHandler,
    );

    if (requestPermissions) {
      await _requestPermissions();
    }
    _initialized = true;
    return _launchPayload();
  }

  Future<void> showWeatherAlertsNotification(int count) async {
    await initialize(requestPermissions: false);

    final title = count == 1
        ? 'Weather alert for tomorrow'
        : '$count weather alerts for tomorrow';
    const body = 'Tap to review rain and severe weather alerts.';

    await _plugin.show(
      id: 1001,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_alerts',
          'Weather alerts',
          channelDescription: 'Rain and severe weather alerts',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.status,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        linux: LinuxNotificationDetails(
          urgency: LinuxNotificationUrgency.normal,
        ),
        windows: WindowsNotificationDetails(),
      ),
      payload: weatherAlertsPayload,
    );
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<String?> _launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }

  static bool opensAlerts(String? payload) => payload == weatherAlertsPayload;
}

@pragma('vm:entry-point')
void notificationTapBackgroundHandler(NotificationResponse response) {}
