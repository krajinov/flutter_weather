// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Weather App';

  @override
  String get home => 'HOME';

  @override
  String get map => 'MAP';

  @override
  String get alerts => 'ALERTS';

  @override
  String get settings => 'SETTINGS';

  @override
  String get retry => 'Retry';

  @override
  String get weatherAlerts => 'Weather Alerts';

  @override
  String get errorLoadingWeather => 'Error loading weather';

  @override
  String get errorLoadingAlerts => 'Error loading alerts';

  @override
  String get errorLoadingLocation => 'Error loading location';

  @override
  String get noAlerts => 'No alerts right now';

  @override
  String get today => 'Today';

  @override
  String get feelsLike => 'Feels Like';

  @override
  String get humidity => 'Humidity';

  @override
  String get windSpeed => 'Wind Speed';

  @override
  String get hourlyForecast => 'Hourly Forecast';

  @override
  String get next3Days => 'Next 3 Days';

  @override
  String get rain => 'Rain';

  @override
  String get temperature => 'Temperature';

  @override
  String get wind => 'Wind';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get addCity => 'Add City';

  @override
  String get temperatureUnit => 'Temperature Unit';

  @override
  String get rainAlerts => 'Rain Alerts';

  @override
  String get severeWeatherAlerts => 'Severe Weather Alerts';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get locationDisabled => 'Location services are disabled.';

  @override
  String get locationDenied => 'Location permissions are denied';

  @override
  String get locationPermanentlyDenied =>
      'Location permissions are permanently denied, we cannot request permissions.';

  @override
  String get unknownCity => 'Unknown City';

  @override
  String tempCelsius(String temp) {
    return '$temp °C';
  }

  @override
  String get radar => 'Radar';

  @override
  String get clouds => 'Clouds';

  @override
  String get rainfall => 'Rainfall';

  @override
  String get uvIndex => 'UV Index';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get sunset => 'Sunset';

  @override
  String get chanceOfRain => 'Chance of Rain';

  @override
  String get airQuality => 'Air Quality';

  @override
  String get searchCity => 'Search city or place';
}
