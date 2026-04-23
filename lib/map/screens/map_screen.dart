import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/nominatim_service.dart';
import '../../home/providers/location_provider.dart';
import '../../home/providers/weather_provider.dart';
import '../widgets/layer_toggles.dart';
import '../widgets/map_overlay_widgets.dart';
import '../widgets/bottom_weather_sheet.dart';
import '../widgets/floating_search_bar.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';
import '../../core/utils/preview_helper.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  int _activeLayer = -1; // -1 = no overlay active
  final MapController _mapController = MapController();
  final NominatimService _nominatimService = NominatimService();
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  
  double _sheetExtent = 0.15; // default min child size

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetExtentChanged);
  }

  void _onSheetExtentChanged() {
    if (_sheetController.isAttached) {
      setState(() {
        _sheetExtent = _sheetController.size;
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    ref.read(selectedLocationProvider.notifier).updateLocation(point);
    _mapController.move(point, _mapController.camera.zoom);
  }

  void _onSuggestionSelected(PlaceSuggestion suggestion) {
    final newPoint = LatLng(suggestion.latitude, suggestion.longitude);
    ref.read(selectedLocationProvider.notifier).updateLocation(newPoint);
    _mapController.move(newPoint, 12.0);
  }

  void _onLayerChanged(int tapped) {
    setState(() => _activeLayer = (_activeLayer == tapped) ? -1 : tapped);
  }

  static const _overlayLayers = [
    'precipitation_new', // Radar
    'temp_new',          // Temperature
    'wind_new',          // Wind
    'clouds_new',        // Clouds
    'rain_new',          // Rainfall
  ];

  String _overlayUrlForLayer(int layer) {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    return 'https://tile.openweathermap.org/map/${_overlayLayers[layer]}/{z}/{x}/{y}.png?appid=$apiKey';
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetExtentChanged);
    _sheetController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsyncValue = ref.watch(weatherProvider);
    final locationAsyncValue = ref.watch(locationProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF071327),
      body: weatherAsyncValue.when(
        data: (weatherData) {
          return locationAsyncValue.when(
            data: (position) {
              final latLng = selectedLocation ?? LatLng(position.latitude, position.longitude);
              
              // Calculate bottom offset for map layer chips
              final screenHeight = MediaQuery.of(context).size.height;
              final chipsBottomOffset = (screenHeight * _sheetExtent) + 16;

              return Stack(
                children: [
                  // 1. Full screen map
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: latLng,
                      initialZoom: 13.0,
                      onTap: _onMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.flutter_weather',
                      ),
                      // Weather overlay tile layer (only when a chip is active)
                      if (_activeLayer != -1)
                        Opacity(
                          opacity: 0.7,
                          child: TileLayer(
                            urlTemplate: _overlayUrlForLayer(_activeLayer),
                            userAgentPackageName: 'com.example.flutter_weather',
                          ),
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

                  // 2. Draggable Bottom Sheet
                  PremiumWeatherSheet(
                    weatherData: weatherData,
                    controller: _sheetController,
                  ),

                  // 3. Floating Map Layer Chips
                  Positioned(
                    bottom: chipsBottomOffset,
                    left: 20,
                    right: 20,
                    child: MapLayerChips(
                      activeLayer: _activeLayer,
                      onLayerChanged: _onLayerChanged,
                    ),
                  ),

                  // 4. Floating Search Bar
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 20,
                    right: 20,
                    child: FloatingSearchBar(
                      currentPosition: latLng,
                      onSuggestionSelected: _onSuggestionSelected,
                      nominatimService: _nominatimService,
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

@Preview(
  name: 'Map Screen',
  group: 'Screens',
  size: Size(390, 844),
)
Widget mapScreenPreview() {
  return localizedPreview(
    const MapScreen(),
    useProviderScope: true,
  );
}
