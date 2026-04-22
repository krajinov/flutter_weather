import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../home/providers/location_provider.dart';
import '../../home/providers/weather_provider.dart';
import '../widgets/layer_toggles.dart';
import '../widgets/map_overlay_widgets.dart';
import '../widgets/map_weather_card.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  int _activeLayer = 0; // 0 = Rain, 1 = Temperature, 2 = Wind

  @override
  Widget build(BuildContext context) {
    final weatherAsyncValue = ref.watch(weatherProvider);
    final locationAsyncValue = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF071327),
      body: weatherAsyncValue.when(
        data: (weatherData) {
          return locationAsyncValue.when(
            data: (position) {
              final latLng = LatLng(position.latitude, position.longitude);

              return Stack(
                children: [
                  // Full screen map
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: latLng,
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.flutter_weather',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: latLng,
                            width: 60,
                            height: 60,
                            child: const MapPin(),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // SafeArea for overlays to prevent dipping under notch
                  SafeArea(
                    child: Stack(
                      children: [
                        // Header: City name + Search
                        Positioned(
                          top: 16,
                          left: 20,
                          right: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.cardColor.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  weatherData.city,
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SearchButton(),
                            ],
                          ),
                        ),

                        // Layer toggles
                        Positioned(
                          bottom: 226,
                          left: 20,
                          right: 20,
                          child: LayerToggles(
                            activeLayer: _activeLayer,
                            onLayerChanged: (layer) => setState(() => _activeLayer = layer),
                          ),
                        ),

                        // Bottom weather card
                        Positioned(
                          bottom: 12,
                          left: 20,
                          right: 20,
                          child: MapWeatherCard(weatherData: weatherData),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.statusIconActive),
            ),
            error: (error, stack) => Center(
              child: Text('${AppLocalizations.of(context)!.errorLoadingLocation}: $error', style: const TextStyle(color: Colors.white)),
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
                  '${AppLocalizations.of(context)!.errorLoadingWeather}\n${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(weatherProvider.future),
                  child: Text(AppLocalizations.of(context)!.retry),
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
  name: 'Map Screen',
  group: 'Screens',
  size: Size(390, 844),
  theme: mapScreenDarkTheme,
)
Widget mapScreenPreview() => const MapScreen();

PreviewThemeData mapScreenDarkTheme() {
  return PreviewThemeData(
    materialDark: AppTheme.darkTheme,
  );
}
