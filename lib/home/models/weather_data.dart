import 'package:intl/intl.dart';
import '../../alerts/models/alert_data.dart';

class WeatherData {
  final String city;
  final int temperature;
  final String condition;
  final int feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double uvi;
  final DateTime sunrise;
  final DateTime sunset;
  final double pop; // Chance of precipitation (0 to 1)
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final List<AlertData> alerts;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.uvi,
    required this.sunrise,
    required this.sunset,
    required this.pop,
    required this.hourly,
    required this.daily,
    required this.alerts,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String city) {
    final current = json['current'];
    final hourlyJson = json['hourly'] as List;
    final dailyJson = json['daily'] as List;
    final alertsJson = json['alerts'] as List?;

    // Take next 24 hours for hourly forecast
    final parsedHourly = hourlyJson
        .take(24)
        .map((e) => HourlyForecast.fromJson(e))
        .toList();

    // Take next 7 days for daily forecast
    final parsedDaily = dailyJson
        .map((e) => DailyForecast.fromJson(e))
        .toList();
        
    final parsedAlerts = alertsJson != null 
        ? alertsJson.map((e) => AlertData.fromJson(e)).toList() 
        : <AlertData>[];

    // Calculate max pop for the next 3 hours
    double maxPop = 0.0;
    for (int i = 0; i < 3 && i < hourlyJson.length; i++) {
      final hourPop = (hourlyJson[i]['pop'] as num?)?.toDouble() ?? 0.0;
      if (hourPop > maxPop) {
        maxPop = hourPop;
      }
    }

    return WeatherData(
      city: city,
      temperature: (current['temp'] as num).round(),
      condition: _mapWeatherCondition(current['weather'][0]['main']),
      feelsLike: (current['feels_like'] as num).round(),
      humidity: current['humidity'] as int,
      windSpeed: (current['wind_speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: (current['wind_deg'] as num?)?.round() ?? 0,
      uvi: (current['uvi'] as num?)?.toDouble() ?? 0.0,
      sunrise: DateTime.fromMillisecondsSinceEpoch((current['sunrise'] as int? ?? 0) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch((current['sunset'] as int? ?? 0) * 1000),
      pop: maxPop,
      hourly: parsedHourly,
      daily: parsedDaily,
      alerts: parsedAlerts,
    );
  }

  static String _mapWeatherCondition(String main) {
    switch (main.toLowerCase()) {
      case 'clear': return 'Sunny';
      case 'clouds': return 'Cloudy';
      case 'rain':
      case 'drizzle': return 'Rain';
      case 'thunderstorm': return 'Storm';
      case 'snow': return 'Snow';
      default: return 'Cloudy';
    }
  }
}


class HourlyForecast {
  final String time;
  final int temperature;
  final String iconDescriptor; // e.g., 'sun', 'cloud', 'rain'

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.iconDescriptor,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final dt = DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000);
    final timeStr = DateFormat('HH:mm').format(dt);

    return HourlyForecast(
      time: timeStr,
      temperature: (json['temp'] as num).round(),
      iconDescriptor: _mapIconDescriptor(json['weather'][0]['main']),
    );
  }
}

class DailyForecast {
  final String dayName;
  final int minTemp;
  final int maxTemp;
  final String iconDescriptor;

  DailyForecast({
    required this.dayName,
    required this.minTemp,
    required this.maxTemp,
    required this.iconDescriptor,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final dt = DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000);
    // Determine if it's today
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final dayStr = isToday ? 'Today' : DateFormat('EE').format(dt); // e.g., "Mon"

    return DailyForecast(
      dayName: dayStr,
      minTemp: (json['temp']['min'] as num).round(),
      maxTemp: (json['temp']['max'] as num).round(),
      iconDescriptor: _mapIconDescriptor(json['weather'][0]['main']),
    );
  }
}

String _mapIconDescriptor(String main) {
  switch (main.toLowerCase()) {
    case 'clear': return 'sun';
    case 'clouds': return 'cloud';
    case 'rain':
    case 'drizzle': return 'rain';
    case 'thunderstorm': return 'lightning';
    case 'snow': return 'snow';
    default: return 'cloud';
  }
}
