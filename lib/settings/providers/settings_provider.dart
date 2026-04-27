import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/background_weather_scheduler.dart';
import '../models/app_settings.dart';
import '../services/settings_storage.dart';

final settingsStorageProvider = Provider<SettingsStorage>((ref) {
  return SettingsStorage();
});

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

class AppSettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final settings = await ref.watch(settingsStorageProvider).load();
    await BackgroundWeatherScheduler.configureForSettings(settings);
    return settings;
  }

  Future<void> setUseCurrentLocation(bool value) {
    return _update((settings) => settings.copyWith(useCurrentLocation: value));
  }

  Future<void> setTemperatureUnit({required bool isCelsius}) {
    return _update((settings) => settings.copyWith(isCelsius: isCelsius));
  }

  Future<void> setRainAlertsEnabled(bool value) {
    return _update((settings) => settings.copyWith(rainAlertsEnabled: value));
  }

  Future<void> setSevereAlertsEnabled(bool value) {
    return _update((settings) => settings.copyWith(severeAlertsEnabled: value));
  }

  Future<void> setDarkMode(bool value) {
    return _update((settings) => settings.copyWith(darkMode: value));
  }

  Future<void> setSelectedLocation({
    required String placeName,
    required double latitude,
    required double longitude,
  }) {
    return _update(
      (settings) => settings.copyWith(
        useCurrentLocation: false,
        selectedPlaceName: placeName,
        selectedLatitude: latitude,
        selectedLongitude: longitude,
      ),
    );
  }

  Future<void> _update(
    AppSettings Function(AppSettings settings) transform,
  ) async {
    final current = state.value ?? await future;
    final next = transform(current);
    state = AsyncData(next);
    await ref.read(settingsStorageProvider).save(next);
    await BackgroundWeatherScheduler.configureForSettings(next);
  }
}
