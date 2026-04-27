import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/alerts/models/alert_data.dart';
import 'package:flutter_weather/core/services/weather_alert_checker.dart';
import 'package:flutter_weather/home/models/weather_data.dart';
import 'package:flutter_weather/settings/models/app_settings.dart';

void main() {
  AlertData alert({
    required String event,
    required String description,
    required DateTime start,
  }) {
    return AlertData.fromJson({
      'event': event,
      'description': description,
      'start': start.millisecondsSinceEpoch ~/ 1000,
      'end': start.add(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
    });
  }

  WeatherData weatherWith(List<AlertData> alerts) {
    return WeatherData(
      city: 'Sarajevo',
      temperature: 20,
      condition: 'Rain',
      feelsLike: 20,
      humidity: 70,
      windSpeed: 4,
      windDirection: 180,
      uvi: 2,
      sunrise: DateTime(2026, 4, 24, 6),
      sunset: DateTime(2026, 4, 24, 19),
      pop: 0.8,
      hourly: const [],
      daily: const [],
      alerts: alerts,
    );
  }

  test('filters next-day rain and severe alerts using settings', () {
    final now = DateTime(2026, 4, 24, 9);
    final rain = alert(
      event: 'Heavy rain',
      description: 'Localized flooding possible',
      start: now.add(const Duration(hours: 4)),
    );
    final severe = alert(
      event: 'Severe thunderstorm warning',
      description: 'Damaging wind and hail possible',
      start: now.add(const Duration(hours: 8)),
    );
    final later = alert(
      event: 'Heavy rain',
      description: 'Rain expected later in the week',
      start: now.add(const Duration(days: 2)),
    );

    final matches = WeatherAlertChecker.filterNextDayAlerts(
      weatherWith([rain, severe, later]),
      const AppSettings(rainAlertsEnabled: true, severeAlertsEnabled: false),
      now: now,
    );

    expect(matches, [rain]);
    expect(rain.isRainAlert, isTrue);
    expect(severe.isSevereAlert, isTrue);
  });
}
