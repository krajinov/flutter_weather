import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/settings_section.dart';
import '../widgets/toggle_switch.dart';
import '../widgets/unit_selector.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';
import '../../core/utils/preview_helper.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _currentLocation = true;
  bool _isCelsius = true;
  bool _rainAlerts = true;
  bool _severeAlerts = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  color: AppColors.textPrimary,
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
                      value: _currentLocation,
                      onChanged: (v) => setState(() => _currentLocation = v),
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
                    onTap: () {},
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
                      isCelsius: _isCelsius,
                      onChanged: (v) => setState(() => _isCelsius = v),
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
                      value: _rainAlerts,
                      onChanged: (v) => setState(() => _rainAlerts = v),
                    ),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: LucideIcons.alertTriangle,
                    label: AppLocalizations.of(context)!.severeWeatherAlerts,
                    trailing: ToggleSwitch(
                      value: _severeAlerts,
                      onChanged: (v) => setState(() => _severeAlerts = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Appearance Section
              SettingsSection(
                children: [
                  SettingsRow(
                    icon: LucideIcons.moon,
                    label: AppLocalizations.of(context)!.darkMode,
                    trailing: ToggleSwitch(
                      value: _darkMode,
                      onChanged: (v) => setState(() => _darkMode = v),
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


@Preview(
  name: 'Settings Screen',
  group: 'Screens',
  size: Size(390, 844),
)
Widget settingsScreenPreview() {
  return localizedPreview(const SettingsScreen());
}

