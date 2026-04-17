import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../core/utils/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../models/weather_data.dart';
import 'glass_card.dart';

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
                Text(
                  'Feels Like',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.feelsLike} C',
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
                Text(
                  'Humidity',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
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
  return Scaffold(
    backgroundColor: AppColors.background,
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: QuickStatsGrid(data: MockData.sarajevoWeather),
    ),
  );
}
