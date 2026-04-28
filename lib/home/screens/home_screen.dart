import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/preview_helper.dart';
import '../../map/screens/map_screen.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../providers/navigation_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/home_weather_overview.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(selectedTabProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: _LazyTabStack(index: currentIndex),
      bottomNavigationBar: Container(
        height: 88,
        decoration: BoxDecoration(
          color: isDark ? AppColors.navBarColor : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF243447) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.statusIconActive,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          currentIndex: currentIndex,
          onTap: (index) =>
              ref.read(selectedTabProvider.notifier).select(index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.home),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.mapPin),
              label: AppLocalizations.of(context)!.map,
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.bell),
              label: AppLocalizations.of(context)!.alerts,
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.settings),
              label: AppLocalizations.of(context)!.settings,
            ),
          ],
        ),
      ),
    );
  }
}

class _LazyTabStack extends StatefulWidget {
  final int index;

  const _LazyTabStack({required this.index});

  @override
  State<_LazyTabStack> createState() => _LazyTabStackState();
}

class _LazyTabStackState extends State<_LazyTabStack> {
  final Set<int> _loadedIndexes = {SelectedTabController.home};

  static const _screens = [
    _HomeContent(),
    MapScreen(),
    AlertsScreen(),
    SettingsScreen(),
  ];

  @override
  void didUpdateWidget(covariant _LazyTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadedIndexes.add(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    _loadedIndexes.add(widget.index);

    return IndexedStack(
      index: widget.index,
      children: List.generate(_screens.length, (index) {
        if (_loadedIndexes.contains(index)) {
          return _screens[index];
        }
        return const SizedBox.shrink();
      }),
    );
  }
}

/// The home tab content that consumes real weather data.
class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsyncValue = ref.watch(weatherProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF071327) : const Color(0xFFF5F7FB),
      child: SafeArea(
        child: weatherAsyncValue.when(
          data: (weatherData) {
            return HomeWeatherOverview(data: weatherData);
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
                  const Icon(
                    LucideIcons.alertCircle,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${AppLocalizations.of(context)!.errorLoadingWeather}\n${error.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(weatherProvider.future),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
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

@Preview(name: 'Home Screen', group: 'Screens', size: Size(390, 844))
Widget homeScreenPreview() {
  return localizedPreview(const HomeScreen(), useProviderScope: true);
}
