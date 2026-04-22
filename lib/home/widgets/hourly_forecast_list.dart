import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../core/utils/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../models/weather_data.dart';
import 'glass_card.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class HourlyForecastList extends StatelessWidget {
  final List<HourlyForecast> forecasts;

  const HourlyForecastList({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.hourlyForecast,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: forecasts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final forecast = forecasts[index];
              return GlassCard(
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    Text(
                      AppLocalizations.of(context)!.tempCelsius(forecast.temperature.toString()),
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
  return Scaffold(
    backgroundColor: AppColors.background,
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: HourlyForecastList(forecasts: MockData.sarajevoWeather.hourly),
      ),
    ),
  );
}
