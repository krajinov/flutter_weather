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
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  LatLng? _lastAppliedCenter;

  double _sheetExtent = 0.15; // default min child size

  static const LatLng _fallbackCenter = LatLng(43.8563, 18.4131);

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
    // Dismiss keyboard and search suggestions when tapping the map
    FocusManager.instance.primaryFocus?.unfocus();
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
    'temp_new', // Temperature
    'wind_new', // Wind
    'clouds_new', // Clouds
    'pressure_new', // Pressure
  ];

  String _overlayUrlForLayer(int layer) {
    const apiKeyFromEnvironment = String.fromEnvironment('OPENWEATHER_API_KEY');
    final apiKey = apiKeyFromEnvironment.isNotEmpty
        ? apiKeyFromEnvironment
        : dotenv.isInitialized
        ? dotenv.env['OPENWEATHER_API_KEY'] ?? ''
        : '';
    return 'https://tile.openweathermap.org/map/${_overlayLayers[layer]}/{z}/{x}/{y}.png?appid=$apiKey';
  }

  void _moveMapIfNeeded(LatLng center) {
    if (_lastAppliedCenter?.latitude == center.latitude &&
        _lastAppliedCenter?.longitude == center.longitude) {
      return;
    }

    _lastAppliedCenter = center;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        _mapController.move(center, _mapController.camera.zoom);
      } catch (_) {
        // The controller can be momentarily unattached in widget tests.
      }
    });
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
    final gpsPosition = locationAsyncValue.whenOrNull(
      data: (position) => position,
    );
    final latLng =
        selectedLocation ??
        (gpsPosition != null
            ? LatLng(gpsPosition.latitude, gpsPosition.longitude)
            : _fallbackCenter);
    final weatherData = weatherAsyncValue.whenOrNull(data: (data) => data);
    final screenHeight = MediaQuery.of(context).size.height;
    final chipsBottomOffset = weatherData != null
        ? (screenHeight * _sheetExtent) + 16
        : 116.0;

    _moveMapIfNeeded(latLng);

    return Scaffold(
      backgroundColor: const Color(0xFF071327),
      body: Stack(
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
          if (weatherData != null)
            PremiumWeatherSheet(
              weatherData: weatherData,
              controller: _sheetController,
            )
          else
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: _WeatherStatusCard(weatherAsyncValue: weatherAsyncValue),
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

          if (selectedLocation == null && locationAsyncValue.hasError)
            Positioned(
              top: MediaQuery.of(context).padding.top + 78,
              left: 20,
              right: 20,
              child: const _LocationStatusBanner(),
            ),
        ],
      ),
    );
  }
}

class _WeatherStatusCard extends ConsumerWidget {
  final AsyncValue<dynamic> weatherAsyncValue;

  const _WeatherStatusCard({required this.weatherAsyncValue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = weatherAsyncValue.isLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xE60D1E30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x337FA5C8)),
      ),
      child: Row(
        children: [
          isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.statusIconActive,
                  ),
                )
              : const Icon(
                  LucideIcons.alertCircle,
                  color: Colors.redAccent,
                  size: 24,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isLoading ? l10n.loadingWeather : l10n.errorLoadingWeather,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          if (!isLoading)
            TextButton(
              onPressed: () => ref.invalidate(weatherProvider),
              child: Text(l10n.retry),
            ),
        ],
      ),
    );
  }
}

class _LocationStatusBanner extends StatelessWidget {
  const _LocationStatusBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xE60D1E30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x337FA5C8)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.mapPinOff,
            color: Colors.amberAccent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.errorLoadingLocation,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

@Preview(name: 'Map Screen', group: 'Screens', size: Size(390, 844))
Widget mapScreenPreview() {
  return localizedPreview(const MapScreen(), useProviderScope: true);
}
