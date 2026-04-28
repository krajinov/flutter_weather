import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/services/weather_api_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/weather_data.dart';
import 'location_provider.dart';

final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  return WeatherApiService();
});

typedef _WeatherLocationSettings = ({
  bool useCurrentLocation,
  String? selectedPlaceName,
  double? selectedLatitude,
  double? selectedLongitude,
});

final _weatherLocationSettingsProvider =
    FutureProvider<_WeatherLocationSettings>((ref) {
      return ref.watch(
        appSettingsProvider.selectAsync(
          (settings) => (
            useCurrentLocation: settings.useCurrentLocation,
            selectedPlaceName: settings.selectedPlaceName,
            selectedLatitude: settings.selectedLatitude,
            selectedLongitude: settings.selectedLongitude,
          ),
        ),
      );
    });

final weatherProvider = FutureProvider<WeatherData>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  final weatherApiService = ref.watch(weatherApiServiceProvider);
  final settings = await ref.watch(_weatherLocationSettingsProvider.future);

  // 1. Check if user selected a location manually.
  final savedSelectedLocation =
      settings.selectedLatitude != null && settings.selectedLongitude != null
      ? LatLng(settings.selectedLatitude!, settings.selectedLongitude!)
      : null;
  final selectedLocation = settings.useCurrentLocation
      ? null
      : savedSelectedLocation ?? ref.watch(selectedLocationProvider);

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
