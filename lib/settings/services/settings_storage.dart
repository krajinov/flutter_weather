import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsStorage {
  static const _useCurrentLocationKey = 'settings.useCurrentLocation';
  static const _isCelsiusKey = 'settings.isCelsius';
  static const _rainAlertsEnabledKey = 'settings.rainAlertsEnabled';
  static const _severeAlertsEnabledKey = 'settings.severeAlertsEnabled';
  static const _darkModeKey = 'settings.darkMode';
  static const _selectedPlaceNameKey = 'settings.selectedPlaceName';
  static const _selectedLatitudeKey = 'settings.selectedLatitude';
  static const _selectedLongitudeKey = 'settings.selectedLongitude';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      useCurrentLocation: prefs.getBool(_useCurrentLocationKey) ?? true,
      isCelsius: prefs.getBool(_isCelsiusKey) ?? true,
      rainAlertsEnabled: prefs.getBool(_rainAlertsEnabledKey) ?? true,
      severeAlertsEnabled: prefs.getBool(_severeAlertsEnabledKey) ?? true,
      darkMode: prefs.getBool(_darkModeKey) ?? true,
      selectedPlaceName: prefs.getString(_selectedPlaceNameKey),
      selectedLatitude: prefs.getDouble(_selectedLatitudeKey),
      selectedLongitude: prefs.getDouble(_selectedLongitudeKey),
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useCurrentLocationKey, settings.useCurrentLocation);
    await prefs.setBool(_isCelsiusKey, settings.isCelsius);
    await prefs.setBool(_rainAlertsEnabledKey, settings.rainAlertsEnabled);
    await prefs.setBool(_severeAlertsEnabledKey, settings.severeAlertsEnabled);
    await prefs.setBool(_darkModeKey, settings.darkMode);

    final placeName = settings.selectedPlaceName;
    final latitude = settings.selectedLatitude;
    final longitude = settings.selectedLongitude;

    if (placeName == null) {
      await prefs.remove(_selectedPlaceNameKey);
    } else {
      await prefs.setString(_selectedPlaceNameKey, placeName);
    }

    if (latitude == null) {
      await prefs.remove(_selectedLatitudeKey);
    } else {
      await prefs.setDouble(_selectedLatitudeKey, latitude);
    }

    if (longitude == null) {
      await prefs.remove(_selectedLongitudeKey);
    } else {
      await prefs.setDouble(_selectedLongitudeKey, longitude);
    }
  }
}
