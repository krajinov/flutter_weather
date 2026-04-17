import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/location_service.dart';
import '../../core/services/weather_api_service.dart';
import '../models/weather_data.dart';
import 'location_provider.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  return WeatherApiService();
});

final weatherProvider = FutureProvider<WeatherData>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  final weatherApiService = ref.watch(weatherApiServiceProvider);
  
  // 1. Get current position directly from the upstream locationProvider
  final position = await ref.watch(locationProvider.future);

  // 2. Resolve city name from coordinates
  final city = await locationService.getCityFromCoordinates(
      position.latitude, position.longitude);

  // 3. Fetch weather data from OpenWeather API
  final weatherData = await weatherApiService.fetchWeather(
      position.latitude, position.longitude, city);

  return weatherData;
});
