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
      HourlyForecast(
        time: '13:00',
        temperature: 22,
        iconDescriptor: 'sun',
        windSpeed: 2.2,
        windDirection: 170,
        pop: 0.05,
        humidity: 56,
      ),
      HourlyForecast(
        time: '16:00',
        temperature: 21,
        iconDescriptor: 'cloud-sun',
        windSpeed: 3.3,
        windDirection: 190,
        pop: 0.2,
        humidity: 62,
      ),
      HourlyForecast(
        time: '19:00',
        temperature: 18,
        iconDescriptor: 'cloud',
        windSpeed: 2.8,
        windDirection: 210,
        pop: 0.14,
        humidity: 67,
      ),
      HourlyForecast(
        time: '22:00',
        temperature: 15,
        iconDescriptor: 'moon',
        windSpeed: 1.9,
        windDirection: 180,
        pop: 0.08,
        humidity: 72,
      ),
    ],
    daily: [
      DailyForecast(
        dayName: 'Thursday',
        minTemp: 14,
        maxTemp: 24,
        iconDescriptor: 'sun',
      ),
      DailyForecast(
        dayName: 'Friday',
        minTemp: 12,
        maxTemp: 21,
        iconDescriptor: 'cloud-sun',
      ),
      DailyForecast(
        dayName: 'Saturday',
        minTemp: 11,
        maxTemp: 20,
        iconDescriptor: 'cloud-rain',
      ),
    ],
    alerts: [],
  );
}
