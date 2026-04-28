import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class AppSettings {
  final bool useCurrentLocation;
  final bool isCelsius;
  final bool rainAlertsEnabled;
  final bool severeAlertsEnabled;
  final bool darkMode;
  final String? selectedPlaceName;
  final double? selectedLatitude;
  final double? selectedLongitude;

  const AppSettings({
    this.useCurrentLocation = true,
    this.isCelsius = true,
    this.rainAlertsEnabled = true,
    this.severeAlertsEnabled = true,
    this.darkMode = true,
    this.selectedPlaceName,
    this.selectedLatitude,
    this.selectedLongitude,
  });

  bool get hasSelectedLocation =>
      selectedLatitude != null && selectedLongitude != null;

  LatLng? get selectedLocation {
    final latitude = selectedLatitude;
    final longitude = selectedLongitude;
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude, longitude);
  }

  ThemeMode get themeMode => darkMode ? ThemeMode.dark : ThemeMode.light;

  bool get anyAlertNotificationsEnabled =>
      rainAlertsEnabled || severeAlertsEnabled;

  int temperatureFor(int celsius) {
    if (isCelsius) return celsius;
    return ((celsius * 9 / 5) + 32).round();
  }

  String formatTemperature(int celsius) {
    final unit = isCelsius ? 'C' : 'F';
    return '${temperatureFor(celsius)} °$unit';
  }

  AppSettings copyWith({
    bool? useCurrentLocation,
    bool? isCelsius,
    bool? rainAlertsEnabled,
    bool? severeAlertsEnabled,
    bool? darkMode,
    String? selectedPlaceName,
    double? selectedLatitude,
    double? selectedLongitude,
    bool clearSelectedLocation = false,
  }) {
    return AppSettings(
      useCurrentLocation: useCurrentLocation ?? this.useCurrentLocation,
      isCelsius: isCelsius ?? this.isCelsius,
      rainAlertsEnabled: rainAlertsEnabled ?? this.rainAlertsEnabled,
      severeAlertsEnabled: severeAlertsEnabled ?? this.severeAlertsEnabled,
      darkMode: darkMode ?? this.darkMode,
      selectedPlaceName: clearSelectedLocation
          ? null
          : selectedPlaceName ?? this.selectedPlaceName,
      selectedLatitude: clearSelectedLocation
          ? null
          : selectedLatitude ?? this.selectedLatitude,
      selectedLongitude: clearSelectedLocation
          ? null
          : selectedLongitude ?? this.selectedLongitude,
    );
  }
}
