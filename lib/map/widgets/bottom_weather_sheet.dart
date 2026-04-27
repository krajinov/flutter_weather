import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../home/models/weather_data.dart';
import '../../settings/models/app_settings.dart';
import '../../settings/providers/settings_provider.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class PremiumWeatherSheet extends ConsumerWidget {
  final WeatherData weatherData;
  final DraggableScrollableController? controller;

  const PremiumWeatherSheet({
    super.key,
    required this.weatherData,
    this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    final colors = _SheetColors.of(context);

    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.15, 0.45, 0.85],
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: colors.sheetColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border.all(color: colors.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadowColor,
                    blurRadius: 30,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  // Drag handle & Collapsed Header
                  SliverToBoxAdapter(
                    child: _buildHeader(context, settings, colors),
                  ),

                  // Half Expanded: Quick Insights Grid
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    sliver: SliverGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.9,
                      children: _buildInsightCards(context, settings, colors),
                    ),
                  ),

                  // Half Expanded: Mini Hourly Forecast (Next 6h)
                  SliverToBoxAdapter(
                    child: _buildMiniHourly(context, settings, colors),
                  ),

                  // Full Expanded: 7-day forecast
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.next3Days, // or 7 days
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...weatherData.daily
                              .take(7)
                              .map(
                                (d) => _buildDailyRow(
                                  context,
                                  d,
                                  settings,
                                  colors,
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppSettings settings,
    _SheetColors colors,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        // Drag handle indicator
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: colors.handleColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  weatherData.condition == 'Sunny'
                      ? LucideIcons.sun
                      : LucideIcons.cloud,
                  color: colors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weatherData.city,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '${weatherData.condition} today', // Summary
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Temp
              Text(
                settings.formatTemperature(weatherData.temperature),
                style: GoogleFonts.dmSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInsightCards(
    BuildContext context,
    AppSettings settings,
    _SheetColors colors,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _InsightCard(
        icon: LucideIcons.thermometer,
        title: l10n.feelsLike,
        value: settings.formatTemperature(weatherData.feelsLike),
        colors: colors,
      ),
      _InsightCard(
        icon: LucideIcons.wind,
        title: l10n.windSpeed,
        value:
            '${weatherData.windSpeedKilometersPerHour.toStringAsFixed(1)} km/h',
        colors: colors,
      ),
      _InsightCard(
        icon: LucideIcons.droplets,
        title: l10n.humidity,
        value: '${weatherData.humidity}%',
        colors: colors,
      ),
      _InsightCard(
        icon: LucideIcons.cloudRain,
        title: l10n.chanceOfRain,
        value: '${(weatherData.pop * 100).round()}%',
        colors: colors,
      ),
      _InsightCard(
        icon: LucideIcons.sunDim,
        title: l10n.uvIndex,
        value: weatherData.uvi.toStringAsFixed(1),
        colors: colors,
      ),
      _InsightCard(
        icon: LucideIcons.sunrise,
        title: l10n.sunrise,
        value: DateFormat('HH:mm').format(weatherData.sunrise),
        colors: colors,
      ),
    ];
  }

  Widget _buildMiniHourly(
    BuildContext context,
    AppSettings settings,
    _SheetColors colors,
  ) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: weatherData.hourly.length > 6
            ? 6
            : weatherData.hourly.length,
        itemBuilder: (context, index) {
          final hour = weatherData.hourly[index];
          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: colors.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.borderColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hour.time,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  hour.iconDescriptor == 'sun'
                      ? LucideIcons.sun
                      : LucideIcons.cloud,
                  color: colors.textPrimary,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  settings.formatTemperature(hour.temperature),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyRow(
    BuildContext context,
    DailyForecast day,
    AppSettings settings,
    _SheetColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              day.dayName,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            day.iconDescriptor == 'sun' ? LucideIcons.sun : LucideIcons.cloud,
            color: colors.textPrimary,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  settings.formatTemperature(day.minTemp),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  settings.formatTemperature(day.maxTemp),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final _SheetColors colors;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                    color: colors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: colors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _SheetColors {
  final Color sheetColor;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color iconBackground;
  final Color handleColor;
  final Color shadowColor;

  const _SheetColors({
    required this.sheetColor,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.iconBackground,
    required this.handleColor,
    required this.shadowColor,
  });

  factory _SheetColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const _SheetColors(
        sheetColor: Color(0xB80D1E30),
        cardColor: Color(0x3313263A),
        borderColor: Color(0x337FA5C8),
        textPrimary: Colors.white,
        textSecondary: Color(0xFFC4D5E4),
        textMuted: Color(0xFF9FB4C8),
        accent: Color(0xFF7CC4FF),
        iconBackground: Color(0x337CC4FF),
        handleColor: Color(0x4DFFFFFF),
        shadowColor: Color(0x73000000),
      );
    }

    return const _SheetColors(
      sheetColor: Colors.white,
      cardColor: Color(0xFFF1F5F9),
      borderColor: Color(0xFFE2E8F0),
      textPrimary: Color(0xFF0F172A),
      textSecondary: Color(0xFF475569),
      textMuted: Color(0xFF64748B),
      accent: Color(0xFF0284C7),
      iconBackground: Color(0xFFE0F2FE),
      handleColor: Color(0xFFCBD5E1),
      shadowColor: Color(0x1A0F172A),
    );
  }
}
