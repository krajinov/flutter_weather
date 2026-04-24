import 'package:flutter_weather/home/models/weather_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  test('applies timezone offset when parsing weather timestamps', () {
    final weather = WeatherData.fromJson({
      'timezone_offset': 7200,
      'current': {
        'temp': 12.4,
        'feels_like': 10.1,
        'humidity': 75,
        'wind_speed': 5.0,
        'wind_deg': 180,
        'uvi': 3.2,
        'sunrise':
            DateTime.utc(2099, 1, 2, 6, 15).millisecondsSinceEpoch ~/ 1000,
        'sunset':
            DateTime.utc(2099, 1, 2, 16, 45).millisecondsSinceEpoch ~/ 1000,
        'weather': [
          {'main': 'Clear'},
        ],
      },
      'hourly': [
        {
          'dt': DateTime.utc(2099, 1, 2, 12).millisecondsSinceEpoch ~/ 1000,
          'temp': 13.0,
          'pop': 0.2,
          'weather': [
            {'main': 'Clear'},
          ],
        },
        {
          'dt': DateTime.utc(2099, 1, 2, 13).millisecondsSinceEpoch ~/ 1000,
          'temp': 14.0,
          'pop': 0.5,
          'weather': [
            {'main': 'Clouds'},
          ],
        },
        {
          'dt': DateTime.utc(2099, 1, 2, 14).millisecondsSinceEpoch ~/ 1000,
          'temp': 15.0,
          'pop': 0.4,
          'weather': [
            {'main': 'Rain'},
          ],
        },
      ],
      'daily': [
        {
          'dt': DateTime.utc(2099, 1, 3).millisecondsSinceEpoch ~/ 1000,
          'temp': {'min': 7.0, 'max': 15.0},
          'weather': [
            {'main': 'Clouds'},
          ],
        },
      ],
    }, 'Sarajevo');

    expect(weather.sunrise.hour, 8);
    expect(weather.sunrise.minute, 15);
    expect(weather.sunset.hour, 18);
    expect(weather.sunset.minute, 45);
    expect(weather.hourly.first.time, '14:00');
    expect(
      weather.daily.first.dayName,
      DateFormat(
        'EE',
      ).format(DateTime.utc(2099, 1, 3).add(const Duration(hours: 2))),
    );
    expect(weather.windSpeedKilometersPerHour, closeTo(18.0, 0.001));
  });
}
