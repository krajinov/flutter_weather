import '../../home/models/weather_data.dart';

class MockData {
  static WeatherData get sarajevoWeather => WeatherData(
        city: 'Sarajevo',
        temperature: 22,
        condition: 'Mostly Sunny',
        feelsLike: 24,
        humidity: 56,
        windSpeed: 12.5,
        windDirection: 180,
        uvi: 5.2,
        sunrise: DateTime(2026, 4, 23, 6, 15),
        sunset: DateTime(2026, 4, 23, 19, 45),
        pop: 0.1,
        hourly: [
          HourlyForecast(time: '13:00', temperature: 22, iconDescriptor: 'sun'),
          HourlyForecast(time: '16:00', temperature: 21, iconDescriptor: 'cloud-sun'),
          HourlyForecast(time: '19:00', temperature: 18, iconDescriptor: 'cloud'),
          HourlyForecast(time: '22:00', temperature: 15, iconDescriptor: 'moon'),
        ],
        daily: [
          DailyForecast(dayName: 'Thursday', minTemp: 14, maxTemp: 24, iconDescriptor: 'sun'),
          DailyForecast(dayName: 'Friday', minTemp: 12, maxTemp: 21, iconDescriptor: 'cloud-sun'),
          DailyForecast(dayName: 'Saturday', minTemp: 11, maxTemp: 20, iconDescriptor: 'cloud-rain'),
        ],
        alerts: [],
      );
}
