import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../core/utils/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/preview_helper.dart';
import '../models/weather_data.dart';
import 'glass_card.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class DailyForecastList extends StatelessWidget {
  final List<DailyForecast> forecasts;

  const DailyForecastList({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.next3Days,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: forecasts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final forecast = forecasts[index];
            return GlassCard(
              borderRadius: 12,
              baseColor: AppColors.dailyCardColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                '${forecast.dayName} ${AppLocalizations.of(context)!.tempCelsius(forecast.maxTemp.toString())} / ${AppLocalizations.of(context)!.tempCelsius(forecast.minTemp.toString())}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFE2E8F0),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
              ),
            );
          },
        ),
      ],
    );
  }
}

@Preview(name: 'Daily Forecast Preview')
Widget dailyForecastPreview() {
  return localizedPreview(
    Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: DailyForecastList(forecasts: MockData.sarajevoWeather.daily),
      ),
    ),
  );
}
