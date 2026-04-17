import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../map/screens/map_screen.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../providers/weather_provider.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/quick_stats_grid.dart';
import '../widgets/weather_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeContent(),
    MapScreen(),
    AlertsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 88,
        decoration: const BoxDecoration(
          color: AppColors.navBarColor,
          border: Border(
            top: BorderSide(color: Color(0xFF243447), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.statusIconActive,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.mapPin),
              label: 'MAP',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.bell),
              label: 'ALERTS',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.settings),
              label: 'SETTINGS',
            ),
          ],
        ),
      ),
    );
  }
}

/// The home tab content that consumes real weather data.
class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsyncValue = ref.watch(weatherProvider);

    return SafeArea(
      child: weatherAsyncValue.when(
        data: (weatherData) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WeatherHeader(data: weatherData),
                const SizedBox(height: 32),
                QuickStatsGrid(data: weatherData),
                const SizedBox(height: 24),
                HourlyForecastList(forecasts: weatherData.hourly),
                const SizedBox(height: 24),
                DailyForecastList(forecasts: weatherData.daily),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.statusIconActive),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.alertCircle, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading weather\n${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(weatherProvider.future),
                  child: const Text('Retry'),
                )
              ],
            ),
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
  name: 'Home Screen',
  group: 'Screens',
  size: Size(390, 844),
  theme: homeScreenDarkTheme,
)
Widget homeScreenPreview() => const HomeScreen();

PreviewThemeData homeScreenDarkTheme() {
  return PreviewThemeData(
    materialDark: AppTheme.darkTheme,
  );
}
