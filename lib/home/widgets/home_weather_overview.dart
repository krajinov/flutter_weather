import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/weather_data.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class HomeWeatherOverview extends StatelessWidget {
  final WeatherData data;

  const HomeWeatherOverview({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeTopBar(data: data),
          const SizedBox(height: 20),
          _CurrentWeatherHero(data: data),
          const SizedBox(height: 18),
          _GlassSheet(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.keyConditions,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                _InsightGrid(data: data),
                const SizedBox(height: 22),
                _SectionTitle(l10n.nextHours),
                const SizedBox(height: 12),
                _HourlyStrip(forecasts: data.hourly.take(8).toList()),
                const SizedBox(height: 24),
                _SectionTitle(l10n.next3Days),
                const SizedBox(height: 12),
                ...data.daily.take(7).map((day) => _DailyRow(day: day)),
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

  const _HomeTopBar({required this.data});

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
                  color: Colors.white,
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
                  color: const Color(0xFFC4D5E4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _IconCircle(
          icon: _weatherIconForCondition(data.condition),
          size: 22,
          iconColor: const Color(0xFF7CC4FF),
        ),
      ],
    );
  }
}

class _CurrentWeatherHero extends StatelessWidget {
  final WeatherData data;

  const _CurrentWeatherHero({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _BlurredPanel(
      radius: 30,
      padding: const EdgeInsets.all(20),
      color: const Color(0x990D1E30),
      child: Row(
        children: [
          _IconCircle(
            icon: _weatherIconForCondition(data.condition),
            size: 32,
            diameter: 64,
            iconColor: const Color(0xFF7CC4FF),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.feelsLikeValue(
                    l10n.tempCelsius(data.feelsLike.toString()),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFC4D5E4),
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
                    color: const Color(0xFF9FB4C8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.tempCelsius(data.temperature.toString()),
            style: GoogleFonts.dmSans(
              fontSize: 44,
              height: 1,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassSheet extends StatelessWidget {
  final Widget child;

  const _GlassSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return _BlurredPanel(
      radius: 32,
      padding: const EdgeInsets.all(20),
      color: const Color(0xB80D1E30),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
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

  const _InsightGrid({required this.data});

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
          itemBuilder: (context, index) => _InsightCard(data: cards[index]),
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

  const _InsightCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x3313263A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x337FA5C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 16, color: const Color(0xFF7CC4FF)),
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
                    color: const Color(0xFF9FB4C8),
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
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyStrip extends StatelessWidget {
  final List<HourlyForecast> forecasts;

  const _HourlyStrip({required this.forecasts});

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
              color: const Color(0x3313263A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x337FA5C8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hour.time,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFC4D5E4),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  _weatherIconForDescriptor(hour.iconDescriptor),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.tempCelsius(hour.temperature.toString()),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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

  const _DailyRow({required this.day});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                color: const Color(0xFFC4D5E4),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Icon(
            _weatherIconForDescriptor(day.iconDescriptor),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l10n.tempCelsius(day.minTemp.toString()),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF7FA5C8),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  l10n.tempCelsius(day.maxTemp.toString()),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

class _BlurredPanel extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final Color color;

  const _BlurredPanel({
    required this.child,
    required this.radius,
    required this.padding,
    required this.color,
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
            border: Border.all(color: const Color(0x337FA5C8)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x59000000),
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

  const _IconCircle({
    required this.icon,
    required this.size,
    this.diameter = 48,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        color: Color(0x337CC4FF),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: size),
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
