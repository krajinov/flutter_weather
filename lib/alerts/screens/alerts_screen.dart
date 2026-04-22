import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../home/providers/weather_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/alerts_empty_state.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsyncValue = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.weatherAlerts,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: weatherAsyncValue.when(
                  data: (weatherData) {
                    final alerts = weatherData.alerts;
                    return alerts.isNotEmpty
                        ? ListView.separated(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: alerts.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return AlertCard(alert: alerts[index]);
                            },
                          )
                        : const AlertsEmptyState();
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.statusIconActive),
                  ),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.alertCircle, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.errorLoadingAlerts,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget Previews
// ─────────────────────────────────────────────────────────────

@Preview(
  name: 'Alerts Screen',
  group: 'Screens',
  size: Size(390, 844),
  theme: alertsScreenDarkTheme,
)
Widget alertsScreenPreview() => const AlertsScreen();

PreviewThemeData alertsScreenDarkTheme() {
  return PreviewThemeData(materialDark: AppTheme.darkTheme);
}
