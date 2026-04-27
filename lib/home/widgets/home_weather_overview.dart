import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../settings/models/app_settings.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/weather_data.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class HomeWeatherOverview extends ConsumerWidget {
  final WeatherData data;

  const HomeWeatherOverview({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    final colors = _WeatherSurfaceColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeTopBar(data: data, colors: colors),
          const SizedBox(height: 20),
          _CurrentWeatherHero(data: data, settings: settings, colors: colors),
          const SizedBox(height: 18),
          _GlassSheet(
            colors: colors,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.keyConditions,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _InsightGrid(data: data, settings: settings, colors: colors),
                const SizedBox(height: 22),
                _SectionTitle(l10n.nextHours, colors: colors),
                const SizedBox(height: 12),
                _HourlyStrip(
                  forecasts: data.hourly.take(8).toList(),
                  settings: settings,
                  colors: colors,
                ),
                const SizedBox(height: 24),
                _SectionTitle(l10n.next3Days, colors: colors),
                const SizedBox(height: 12),
                ...data.daily
                    .take(7)
                    .map(
                      (day) => _DailyRow(
                        day: day,
                        settings: settings,
                        colors: colors,
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

class _HomeTopBar extends StatelessWidget {
  final WeatherData data;
  final _WeatherSurfaceColors colors;

  const _HomeTopBar({required this.data, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${data.condition} today',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _IconCircle(
          icon: _weatherIconForCondition(data.condition),
          size: 22,
          iconColor: colors.accent,
          colors: colors,
        ),
      ],
    );
  }
}

class _CurrentWeatherHero extends StatelessWidget {
  final WeatherData data;
  final AppSettings settings;
  final _WeatherSurfaceColors colors;

  const _CurrentWeatherHero({
    required this.data,
    required this.settings,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _BlurredPanel(
      radius: 30,
      padding: const EdgeInsets.all(20),
      colors: colors,
      color: colors.panelColor,
      child: Row(
        children: [
          _IconCircle(
            icon: _weatherIconForCondition(data.condition),
            size: 32,
            diameter: 64,
            iconColor: colors.accent,
            colors: colors,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.condition,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.feelsLikeValue(
                    settings.formatTemperature(data.feelsLike),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.precipitationChance('${(data.pop * 100).round()}%'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            settings.formatTemperature(data.temperature),
            style: GoogleFonts.dmSans(
              fontSize: 44,
              height: 1,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassSheet extends StatelessWidget {
  final Widget child;
  final _WeatherSurfaceColors colors;

  const _GlassSheet({required this.child, required this.colors});

  @override
  Widget build(BuildContext context) {
    return _BlurredPanel(
      radius: 32,
      padding: const EdgeInsets.all(20),
      colors: colors,
      color: colors.sheetColor,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.handleColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _InsightGrid extends StatelessWidget {
  final WeatherData data;
  final AppSettings settings;
  final _WeatherSurfaceColors colors;

  const _InsightGrid({
    required this.data,
    required this.settings,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cards = [
      _InsightCardData(
        icon: LucideIcons.cloudRain,
        title: l10n.chanceOfRain,
        value: '${(data.pop * 100).round()}%',
      ),
      _InsightCardData(
        icon: LucideIcons.wind,
        title: l10n.windSpeed,
        value: '${data.windSpeedKilometersPerHour.toStringAsFixed(1)} km/h',
      ),
      _InsightCardData(
        icon: LucideIcons.droplets,
        title: l10n.humidity,
        value: '${data.humidity}%',
      ),
      _InsightCardData(
        icon: LucideIcons.sunDim,
        title: l10n.uvIndex,
        value: data.uvi.toStringAsFixed(1),
      ),
      _InsightCardData(
        icon: LucideIcons.sunrise,
        title: l10n.sunrise,
        value: DateFormat('HH:mm').format(data.sunrise),
      ),
      _InsightCardData(
        icon: LucideIcons.sunset,
        title: l10n.sunset,
        value: DateFormat('HH:mm').format(data.sunset),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 520 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 88,
          ),
          itemBuilder: (context, index) =>
              _InsightCard(data: cards[index], colors: colors),
        );
      },
    );
  }
}

class _InsightCardData {
  final IconData icon;
  final String title;
  final String value;

  const _InsightCardData({
    required this.icon,
    required this.title,
    required this.value,
  });
}

class _InsightCard extends StatelessWidget {
  final _InsightCardData data;
  final _WeatherSurfaceColors colors;

  const _InsightCard({required this.data, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 16, color: colors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                    color: colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyStrip extends StatelessWidget {
  final List<HourlyForecast> forecasts;
  final AppSettings settings;
  final _WeatherSurfaceColors colors;

  const _HourlyStrip({
    required this.forecasts,
    required this.settings,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: forecasts.length,
        itemBuilder: (context, index) {
          final hour = forecasts[index];
          return Container(
            width: 70,
            margin: EdgeInsets.only(
              right: index < forecasts.length - 1 ? 12 : 0,
            ),
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
                  _weatherIconForDescriptor(hour.iconDescriptor),
                  color: colors.textPrimary,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  settings.formatTemperature(hour.temperature),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
}

class _DailyRow extends StatelessWidget {
  final DailyForecast day;
  final AppSettings settings;
  final _WeatherSurfaceColors colors;

  const _DailyRow({
    required this.day,
    required this.settings,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(
              day.dayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Icon(
            _weatherIconForDescriptor(day.iconDescriptor),
            color: colors.textPrimary,
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  settings.formatTemperature(day.minTemp),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  settings.formatTemperature(day.maxTemp),
                  style: GoogleFonts.inter(
                    fontSize: 15,
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

class _SectionTitle extends StatelessWidget {
  final String text;
  final _WeatherSurfaceColors colors;

  const _SectionTitle(this.text, {required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }
}

class _BlurredPanel extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final Color color;
  final _WeatherSurfaceColors colors;

  const _BlurredPanel({
    required this.child,
    required this.radius,
    required this.padding,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: colors.borderColor),
            boxShadow: [
              BoxShadow(
                color: colors.shadowColor,
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final double size;
  final double diameter;
  final Color iconColor;
  final _WeatherSurfaceColors colors;

  const _IconCircle({
    required this.icon,
    required this.size,
    this.diameter = 48,
    required this.iconColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: colors.iconBackground,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: size),
    );
  }
}

class _WeatherSurfaceColors {
  final Color panelColor;
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

  const _WeatherSurfaceColors({
    required this.panelColor,
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

  factory _WeatherSurfaceColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const _WeatherSurfaceColors(
        panelColor: Color(0x990D1E30),
        sheetColor: Color(0xB80D1E30),
        cardColor: Color(0x3313263A),
        borderColor: Color(0x337FA5C8),
        textPrimary: Colors.white,
        textSecondary: Color(0xFFC4D5E4),
        textMuted: Color(0xFF9FB4C8),
        accent: Color(0xFF7CC4FF),
        iconBackground: Color(0x337CC4FF),
        handleColor: Color(0x4DFFFFFF),
        shadowColor: Color(0x59000000),
      );
    }

    return const _WeatherSurfaceColors(
      panelColor: Colors.white,
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

IconData _weatherIconForCondition(String condition) {
  switch (condition.toLowerCase()) {
    case 'sunny':
    case 'mostly sunny':
      return LucideIcons.sun;
    case 'rain':
      return LucideIcons.cloudRain;
    case 'storm':
      return LucideIcons.cloudLightning;
    case 'snow':
      return LucideIcons.cloudSnow;
    case 'cloudy':
    default:
      return LucideIcons.cloud;
  }
}

IconData _weatherIconForDescriptor(String descriptor) {
  switch (descriptor.toLowerCase()) {
    case 'sun':
      return LucideIcons.sun;
    case 'cloud-sun':
      return LucideIcons.cloudSun;
    case 'rain':
    case 'cloud-rain':
      return LucideIcons.cloudRain;
    case 'lightning':
      return LucideIcons.cloudLightning;
    case 'snow':
      return LucideIcons.cloudSnow;
    case 'moon':
      return LucideIcons.moon;
    case 'cloud':
    default:
      return LucideIcons.cloud;
  }
}
