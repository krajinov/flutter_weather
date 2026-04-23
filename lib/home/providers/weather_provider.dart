import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/weather_api_service.dart';
import '../models/weather_data.dart';
import 'location_provider.dart';

final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  return WeatherApiService();
});

final weatherProvider = FutureProvider<WeatherData>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  final weatherApiService = ref.watch(weatherApiServiceProvider);
  
  // 1. Check if user selected a location manually
  final selectedLocation = ref.watch(selectedLocationProvider);
  
  double lat;
  double lon;

  if (selectedLocation != null) {
    lat = selectedLocation.latitude;
    lon = selectedLocation.longitude;
  } else {
    // Fallback to GPS location
    final position = await ref.watch(locationProvider.future);
    lat = position.latitude;
    lon = position.longitude;
  }

  // 2. Resolve city name from coordinates
  final city = await locationService.getCityFromCoordinates(lat, lon);

  // 3. Fetch weather data from OpenWeather API
  final weatherData = await weatherApiService.fetchWeather(lat, lon, city);

  return weatherData;
});
