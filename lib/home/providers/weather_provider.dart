import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/weather_api_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/weather_data.dart';
import 'location_provider.dart';

final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  return WeatherApiService();
});

final weatherProvider = FutureProvider<WeatherData>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  final weatherApiService = ref.watch(weatherApiServiceProvider);
  final settings = ref.watch(appSettingsProvider).requireValue;

  // 1. Check if user selected a location manually.
  final selectedLocation = settings.useCurrentLocation
      ? null
      : settings.selectedLocation ?? ref.watch(selectedLocationProvider);

  double lat;
  double lon;
  String? selectedCity;

  if (selectedLocation != null) {
    lat = selectedLocation.latitude;
    lon = selectedLocation.longitude;
    selectedCity = settings.selectedPlaceName;
  } else {
    // Fallback to GPS location
    final position = await ref.watch(locationProvider.future);
    lat = position.latitude;
    lon = position.longitude;
  }

  // 2. Resolve city name from coordinates
  final city =
      selectedCity ?? await locationService.getCityFromCoordinates(lat, lon);

  // 3. Fetch weather data from OpenWeather API
  final weatherData = await weatherApiService.fetchWeather(lat, lon, city);

  return weatherData;
});
