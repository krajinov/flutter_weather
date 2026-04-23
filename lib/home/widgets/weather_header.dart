import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../core/utils/mock_data.dart';
import '../../core/utils/preview_helper.dart';
import '../models/weather_data.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class WeatherHeader extends StatelessWidget {
  final WeatherData data;

  const WeatherHeader({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.city,
          style: theme.bodyMedium,
        ),
        Text(
          AppLocalizations.of(context)!.tempCelsius(data.temperature.toString()),
          style: theme.displayLarge,
        ),
        Text(
          data.condition,
          style: theme.bodyLarge?.copyWith(
            color: const Color(0xFFCBD5E1),
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Weather Header Preview')
Widget weatherHeaderPreview() {
  return localizedPreview(
    Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: WeatherHeader(data: MockData.sarajevoWeather),
      ),
    ),
  );
}
