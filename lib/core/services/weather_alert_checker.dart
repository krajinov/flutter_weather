import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../alerts/models/alert_data.dart';
import '../../home/models/weather_data.dart';
import '../../settings/models/app_settings.dart';
import 'location_service.dart';
import 'weather_api_service.dart';

class WeatherAlertChecker {
  WeatherAlertChecker({
    WeatherApiService? weatherApiService,
    LocationService? locationService,
  }) : _weatherApiService = weatherApiService ?? WeatherApiService(),
       _locationService = locationService ?? LocationService();

  final WeatherApiService _weatherApiService;
  final LocationService _locationService;

  Future<List<AlertData>> checkNextDayAlerts(AppSettings settings) async {
    await _loadDotEnvIfNeeded();

    final coordinates = await _coordinatesFor(settings);
    if (coordinates == null) return const [];

    final city =
        settings.selectedPlaceName ??
        await _locationService.getCityFromCoordinates(
          coordinates.latitude,
          coordinates.longitude,
        );
    final weather = await _weatherApiService.fetchWeather(
      coordinates.latitude,
      coordinates.longitude,
      city,
    );

    return filterNextDayAlerts(weather, settings);
  }

  Future<_Coordinates?> _coordinatesFor(AppSettings settings) async {
    if (!settings.useCurrentLocation && settings.hasSelectedLocation) {
      return _Coordinates(
        latitude: settings.selectedLatitude!,
        longitude: settings.selectedLongitude!,
      );
    }

    try {
      final position = await _locationService.getCurrentPosition();
      return _Coordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      final selectedLocation = settings.selectedLocation;
      if (selectedLocation == null) return null;
      return _Coordinates(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      );
    }
  }

  static List<AlertData> filterNextDayAlerts(
    WeatherData weather,
    AppSettings settings, {
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final cutoff = reference.add(const Duration(days: 1));

    return weather.alerts.where((alert) {
      if (!alert.startsBefore(cutoff)) return false;
      if (alert.isRainAlert && settings.rainAlertsEnabled) return true;
      if (alert.isSevereAlert && settings.severeAlertsEnabled) return true;
      return false;
    }).toList();
  }

  Future<void> _loadDotEnvIfNeeded() async {
    if (dotenv.isInitialized) return;
    try {
      await dotenv.load(fileName: '.env', isOptional: true);
    } catch (_) {
      // Background isolates may not have asset access on every platform.
    }
  }
}

class _Coordinates {
  final double latitude;
  final double longitude;

  const _Coordinates({required this.latitude, required this.longitude});
}
