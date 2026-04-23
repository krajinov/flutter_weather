import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../home/models/weather_data.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class PremiumWeatherSheet extends StatelessWidget {
  final WeatherData weatherData;
  final DraggableScrollableController? controller;

  const PremiumWeatherSheet({
    super.key, 
    required this.weatherData,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
                color: const Color(0xB80D1E30),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: const Color(0x337FA5C8)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x73000000),
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
                    child: _buildHeader(context),
                  ),
                  
                  // Half Expanded: Quick Insights Grid
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    sliver: SliverGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: _buildInsightCards(context),
                    ),
                  ),

                  // Half Expanded: Mini Hourly Forecast (Next 6h)
                  SliverToBoxAdapter(
                    child: _buildMiniHourly(context),
                  ),

                  // Full Expanded: 7-day forecast
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.next3Days, // or 7 days
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...weatherData.daily.take(7).map((d) => _buildDailyRow(context, d)),
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

  Widget _buildHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        // Drag handle indicator
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
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
                  color: const Color(0x337CC4FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  weatherData.condition == 'Sunny' ? LucideIcons.sun : LucideIcons.cloud,
                  color: const Color(0xFF7CC4FF),
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
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${weatherData.condition} today', // Summary
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFC4D5E4),
                      ),
                    ),
                  ],
                ),
              ),
              // Temp
              Text(
                AppLocalizations.of(context)!.tempCelsius(weatherData.temperature.toString()),
                style: GoogleFonts.dmSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInsightCards(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _InsightCard(
        icon: LucideIcons.thermometer,
        title: l10n.feelsLike,
        value: l10n.tempCelsius(weatherData.feelsLike.toString()),
      ),
      _InsightCard(
        icon: LucideIcons.wind,
        title: l10n.windSpeed,
        value: '${weatherData.windSpeed} km/h',
      ),
      _InsightCard(
        icon: LucideIcons.droplets,
        title: l10n.humidity,
        value: '${weatherData.humidity}%',
      ),
      _InsightCard(
        icon: LucideIcons.cloudRain,
        title: l10n.chanceOfRain,
        value: '${(weatherData.pop * 100).round()}%',
      ),
      _InsightCard(
        icon: LucideIcons.sunDim,
        title: l10n.uvIndex,
        value: weatherData.uvi.toStringAsFixed(1),
      ),
      _InsightCard(
        icon: LucideIcons.sunrise,
        title: l10n.sunrise,
        value: DateFormat('HH:mm').format(weatherData.sunrise),
      ),
    ];
  }

  Widget _buildMiniHourly(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: weatherData.hourly.length > 6 ? 6 : weatherData.hourly.length,
        itemBuilder: (context, index) {
          final hour = weatherData.hourly[index];
          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 12),
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
                  hour.iconDescriptor == 'sun' ? LucideIcons.sun : LucideIcons.cloud,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.tempCelsius(hour.temperature.toString()),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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

  Widget _buildDailyRow(BuildContext context, DailyForecast day) {
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
                color: const Color(0xFFC4D5E4),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            day.iconDescriptor == 'sun' ? LucideIcons.sun : LucideIcons.cloud,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  AppLocalizations.of(context)!.tempCelsius(day.minTemp.toString()),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF7FA5C8),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  AppLocalizations.of(context)!.tempCelsius(day.maxTemp.toString()),
                  style: GoogleFonts.inter(
                    fontSize: 16,
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

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x3313263A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x337FA5C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF7CC4FF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9FB4C8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
