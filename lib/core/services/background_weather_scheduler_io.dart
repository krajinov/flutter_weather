import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../settings/models/app_settings.dart';
import '../../settings/services/settings_storage.dart';
import 'local_notification_service.dart';
import 'weather_alert_checker.dart';

const _weatherAlertTaskUniqueName = 'weather-alert-check';
const _weatherAlertTaskName = 'check-next-day-weather-alerts';

class BackgroundWeatherScheduler {
  static Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    await Workmanager().initialize(weatherAlertCallbackDispatcher);
  }

  static Future<void> configureForSettings(AppSettings settings) async {
    if (!Platform.isAndroid) return;

    if (!settings.anyAlertNotificationsEnabled) {
      await Workmanager().cancelByUniqueName(_weatherAlertTaskUniqueName);
      return;
    }

    await Workmanager().registerPeriodicTask(
      _weatherAlertTaskUniqueName,
      _weatherAlertTaskName,
      frequency: const Duration(hours: 6),
      initialDelay: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }
}

@pragma('vm:entry-point')
void weatherAlertCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    if (taskName != _weatherAlertTaskName) return true;

    try {
      final settings = await SettingsStorage().load();
      if (!settings.anyAlertNotificationsEnabled) return true;

      final alerts = await WeatherAlertChecker().checkNextDayAlerts(settings);
      if (alerts.isNotEmpty) {
        await LocalNotificationService.instance.showWeatherAlertsNotification(
          alerts.length,
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  });
}
