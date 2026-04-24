import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/utils/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/preview_helper.dart';
import '../models/weather_data.dart';
import 'glass_card.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class QuickStatsGrid extends StatelessWidget {
  final WeatherData data;

  const QuickStatsGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.feelsLike,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const Icon(LucideIcons.thermometer, size: 16, color: AppColors.statusIconActive),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.tempCelsius(data.feelsLike.toString()),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.humidity,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const Icon(LucideIcons.droplets, size: 16, color: AppColors.statusIconActive),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${data.humidity}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Quick Stats Preview')
Widget quickStatsPreview() {
  return localizedPreview(
    Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: QuickStatsGrid(data: MockData.sarajevoWeather),
      ),
    ),
  );
}
