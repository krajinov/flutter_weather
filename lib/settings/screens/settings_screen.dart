import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/nominatim_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/city_picker_dialog.dart';
import '../widgets/settings_section.dart';
import '../widgets/toggle_switch.dart';
import '../widgets/unit_selector.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';
import '../../core/utils/preview_helper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickCity(BuildContext context, WidgetRef ref) async {
    final suggestion = await showDialog<PlaceSuggestion>(
      context: context,
      builder: (_) => const CityPickerDialog(),
    );
    if (suggestion == null) return;

    await ref
        .read(appSettingsProvider.notifier)
        .setSelectedLocation(
          placeName: suggestion.displayName.split(',').first.trim(),
          latitude: suggestion.latitude,
          longitude: suggestion.longitude,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final settings = settingsAsync.value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (settings == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.statusIconActive),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.settings,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Location Section
              SettingsSection(
                children: [
                  SettingsRow(
                    icon: LucideIcons.mapPin,
                    label: AppLocalizations.of(context)!.currentLocation,
                    trailing: ToggleSwitch(
                      value: settings.useCurrentLocation,
                      onChanged: (value) async {
                        if (!value && !settings.hasSelectedLocation) {
                          await _pickCity(context, ref);
                          return;
                        }
                        await ref
                            .read(appSettingsProvider.notifier)
                            .setUseCurrentLocation(value);
                      },
                    ),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: LucideIcons.plus,
                    label: AppLocalizations.of(context)!.addCity,
                    trailing: const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () => _pickCity(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Units Section
              SettingsSection(
                children: [
                  SettingsRow(
                    icon: LucideIcons.thermometer,
                    label: AppLocalizations.of(context)!.temperatureUnit,
                    trailing: UnitSelector(
                      isCelsius: settings.isCelsius,
                      onChanged: (isCelsius) => ref
                          .read(appSettingsProvider.notifier)
                          .setTemperatureUnit(isCelsius: isCelsius),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notifications Section
              SettingsSection(
                children: [
                  SettingsRow(
                    icon: LucideIcons.cloudRain,
                    label: AppLocalizations.of(context)!.rainAlerts,
                    trailing: ToggleSwitch(
                      value: settings.rainAlertsEnabled,
                      onChanged: (value) => ref
                          .read(appSettingsProvider.notifier)
                          .setRainAlertsEnabled(value),
                    ),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: LucideIcons.alertTriangle,
                    label: AppLocalizations.of(context)!.severeWeatherAlerts,
                    trailing: ToggleSwitch(
                      value: settings.severeAlertsEnabled,
                      onChanged: (value) => ref
                          .read(appSettingsProvider.notifier)
                          .setSevereAlertsEnabled(value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Appearance Section
              SettingsSection(
                children: [
                  SettingsRow(
                    icon: isDark ? LucideIcons.moon : LucideIcons.sun,
                    label: AppLocalizations.of(context)!.darkMode,
                    trailing: ToggleSwitch(
                      value: settings.darkMode,
                      onChanged: (value) => ref
                          .read(appSettingsProvider.notifier)
                          .setDarkMode(value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

@Preview(name: 'Settings Screen', group: 'Screens', size: Size(390, 844))
Widget settingsScreenPreview() {
  return localizedPreview(const SettingsScreen());
}
