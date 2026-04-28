import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/core/services/location_service.dart';
import 'package:flutter_weather/core/services/weather_api_service.dart';
import 'package:flutter_weather/core/utils/mock_data.dart';
import 'package:flutter_weather/home/models/weather_data.dart';
import 'package:flutter_weather/home/providers/location_provider.dart';
import 'package:flutter_weather/home/providers/weather_provider.dart';
import 'package:flutter_weather/settings/models/app_settings.dart';
import 'package:flutter_weather/settings/providers/settings_provider.dart';
import 'package:flutter_weather/settings/services/settings_storage.dart';

void main() {
  test('keeps weather loading while settings are loading', () async {
    final settingsStorage = _FakeSettingsStorage.loading();
    final weatherApiService = _FakeWeatherApiService();
    final container = ProviderContainer(
      overrides: [
        settingsStorageProvider.overrideWithValue(settingsStorage),
        weatherApiServiceProvider.overrideWithValue(weatherApiService),
        locationServiceProvider.overrideWithValue(_FakeLocationService()),
      ],
    );
    addTearDown(container.dispose);

    final weatherFuture = container.read(weatherProvider.future);

    await Future<void>.delayed(Duration.zero);

    expect(container.read(weatherProvider).isLoading, isTrue);

    settingsStorage.completeLoad(
      const AppSettings(
        useCurrentLocation: false,
        selectedPlaceName: 'Sarajevo',
        selectedLatitude: 43.8563,
        selectedLongitude: 18.4131,
      ),
    );

    final weather = await weatherFuture;

    expect(weather.city, 'Sarajevo');
    expect(weatherApiService.fetchCount, 1);
  });

  test('does not refetch weather for unrelated settings changes', () async {
    final settingsStorage = _FakeSettingsStorage(
      const AppSettings(
        useCurrentLocation: false,
        selectedPlaceName: 'Sarajevo',
        selectedLatitude: 43.8563,
        selectedLongitude: 18.4131,
      ),
    );
    final weatherApiService = _FakeWeatherApiService();
    final container = ProviderContainer(
      overrides: [
        settingsStorageProvider.overrideWithValue(settingsStorage),
        weatherApiServiceProvider.overrideWithValue(weatherApiService),
        locationServiceProvider.overrideWithValue(_FakeLocationService()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(weatherProvider.future);
    expect(weatherApiService.fetchCount, 1);

    await container.read(appSettingsProvider.notifier).setDarkMode(false);
    await container
        .read(appSettingsProvider.notifier)
        .setTemperatureUnit(isCelsius: false);
    await container
        .read(appSettingsProvider.notifier)
        .setRainAlertsEnabled(false);
    await Future<void>.delayed(Duration.zero);

    await container.read(weatherProvider.future);

    expect(weatherApiService.fetchCount, 1);
  });
}

class _FakeSettingsStorage extends SettingsStorage {
  AppSettings _settings;
  final Completer<AppSettings>? _loadCompleter;

  _FakeSettingsStorage(this._settings) : _loadCompleter = null;

  _FakeSettingsStorage.loading()
    : _settings = const AppSettings(),
      _loadCompleter = Completer<AppSettings>();

  @override
  Future<AppSettings> load() {
    return _loadCompleter?.future ?? Future.value(_settings);
  }

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
  }

  void completeLoad(AppSettings settings) {
    _settings = settings;
    _loadCompleter?.complete(settings);
  }
}

class _FakeWeatherApiService extends WeatherApiService {
  int fetchCount = 0;

  @override
  Future<WeatherData> fetchWeather(double lat, double lon, String city) async {
    fetchCount++;
    return MockData.sarajevoWeather;
  }
}

class _FakeLocationService extends LocationService {}
