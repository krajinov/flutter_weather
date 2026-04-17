import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../home/models/weather_data.dart';

class WeatherApiService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/3.0/onecall';

  Future<WeatherData> fetchWeather(double lat, double lon, String city) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenWeather API Key is empty or not found in .env file.');
    }

    final url = Uri.parse(
        '$_baseUrl?lat=$lat&lon=$lon&exclude=minutely&units=metric&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return WeatherData.fromJson(data, city);
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }
}
