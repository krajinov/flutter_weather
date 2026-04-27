import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/utils/mock_data.dart';
import '../../core/utils/preview_helper.dart';
import '../../settings/models/app_settings.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/weather_data.dart';

class WeatherHeader extends ConsumerWidget {
  final WeatherData data;

  const WeatherHeader({super.key, required this.data});

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'mostly sunny':
        return LucideIcons.sun;
      case 'cloudy':
        return LucideIcons.cloud;
      case 'rain':
        return LucideIcons.cloudRain;
      case 'storm':
        return LucideIcons.cloudLightning;
      case 'snow':
        return LucideIcons.cloudSnow;
      default:
        return LucideIcons.cloud;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.city, style: theme.bodyMedium),
            Text(
              settings.formatTemperature(data.temperature),
              style: theme.displayLarge,
            ),
            Text(
              data.condition,
              style: theme.bodyLarge?.copyWith(color: const Color(0xFFCBD5E1)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getWeatherIcon(data.condition),
            size: 64,
            color: Colors.white,
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
