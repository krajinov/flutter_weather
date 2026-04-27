import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/utils/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/preview_helper.dart';
import '../../settings/models/app_settings.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/weather_data.dart';
import 'glass_card.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class HourlyForecastList extends ConsumerWidget {
  final List<HourlyForecast> forecasts;

  const HourlyForecastList({super.key, required this.forecasts});

  IconData _getWeatherIcon(String descriptor) {
    switch (descriptor.toLowerCase()) {
      case 'sun':
        return LucideIcons.sun;
      case 'cloud-sun':
        return LucideIcons.cloudSun;
      case 'cloud':
        return LucideIcons.cloud;
      case 'rain':
      case 'cloud-rain':
        return LucideIcons.cloudRain;
      case 'moon':
        return LucideIcons.moon;
      case 'lightning':
        return LucideIcons.cloudLightning;
      case 'snow':
        return LucideIcons.cloudSnow;
      default:
        return LucideIcons.cloud;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.hourlyForecast,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: forecasts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final forecast = forecasts[index];
              return GlassCard(
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      forecast.time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      _getWeatherIcon(forecast.iconDescriptor),
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      settings.formatTemperature(forecast.temperature),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Hourly Forecast Preview')
Widget hourlyForecastPreview() {
  return localizedPreview(
    Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: HourlyForecastList(forecasts: MockData.sarajevoWeather.hourly),
        ),
      ),
    ),
  );
}
