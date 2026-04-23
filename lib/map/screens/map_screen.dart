import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/nominatim_service.dart';
import '../../home/providers/location_provider.dart';
import '../../home/providers/weather_provider.dart';
import '../widgets/layer_toggles.dart';
import '../widgets/map_overlay_widgets.dart';
import '../widgets/bottom_weather_sheet.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';
import '../../core/utils/preview_helper.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  int _activeLayer = 0;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final NominatimService _nominatimService = NominatimService();
  final FocusNode _searchFocusNode = FocusNode();

  List<PlaceSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        // Delay hiding so tap on suggestion registers first
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text;

    // Cancel any previous debounce timer
    _debounceTimer?.cancel();

    if (query.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Debounce: wait 400ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(query);
    });
  }

  Future<List<PlaceSuggestion>> _fetchSuggestions(String query) async {
    if (!mounted) return [];
    setState(() => _isSearching = true);

    // Get current position for biasing results
    final position = ref.read(locationProvider).asData?.value;

    final results = await _nominatimService.searchPlaces(
      query,
      biasLat: position?.latitude,
      biasLon: position?.longitude,
    );

    if (mounted) {
      setState(() {
        _suggestions = results;
        _showSuggestions = results.isNotEmpty;
        _isSearching = false;
      });
    }
    return results;
  }

  void _selectSuggestion(PlaceSuggestion suggestion) {
    final newPoint = LatLng(suggestion.latitude, suggestion.longitude);
    ref.read(selectedLocationProvider.notifier).updateLocation(newPoint);
    _mapController.move(newPoint, 12.0);

    setState(() {
      _searchController.removeListener(_onSearchChanged);
      _searchController.text = suggestion.displayName.split(',').first;
      _searchController.addListener(_onSearchChanged);
      _suggestions = [];
      _showSuggestions = false;
    });

    _searchFocusNode.unfocus();
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    ref.read(selectedLocationProvider.notifier).updateLocation(point);
    _mapController.move(point, _mapController.camera.zoom);
    setState(() => _showSuggestions = false);
    _searchFocusNode.unfocus();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
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

              return Stack(
                children: [
                  // Full screen map
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

                  // Draggable Bottom Sheet (Rendered before overlays so overlays are on top)
                  BottomWeatherSheet(weatherData: weatherData),

                  // Search Bar & Suggestions (Positioned at the top)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search bar
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xE00D1E30), // Increased opacity
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: const Color(0x337FA5C8)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x40000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.searchCity,
                              hintStyle: const TextStyle(color: Color(0xFFAFC2D3)),
                              prefixIcon: const Icon(LucideIcons.search, color: Color(0xFF7CC4FF)),
                              suffixIcon: _isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(14.0),
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7CC4FF)),
                                    )
                                  : _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(LucideIcons.x, color: Color(0xFF7CC4FF)),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _suggestions = [];
                                              _showSuggestions = false;
                                            });
                                          },
                                        )
                                      : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                          ),
                        ),

                        // Suggestions dropdown
                        if (_showSuggestions && _suggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            constraints: const BoxConstraints(maxHeight: 400),
                            decoration: BoxDecoration(
                              color: const Color(0xF20D1E30), // Solider background
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0x337FA5C8)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x60000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: _suggestions.length,
                                separatorBuilder: (_, _) => Divider(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  height: 1,
                                  indent: 52,
                                ),
                                itemBuilder: (context, index) {
                                  final suggestion = _suggestions[index];
                                  final parts = suggestion.displayName.split(',');
                                  final city = parts.first.trim();
                                  final region = parts.length > 1
                                      ? parts.sublist(1).join(',').trim()
                                      : '';

                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _selectSuggestion(suggestion),
                                      splashColor: const Color(0x207CC4FF),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: const Color(0x207CC4FF),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                LucideIcons.mapPin,
                                                size: 16,
                                                color: Color(0xFF7CC4FF),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    city,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  if (region.isNotEmpty)
                                                    Text(
                                                      region,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        color: const Color(0xFF9FB4C8),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              LucideIcons.arrowRight,
                                              size: 14,
                                              color: Color(0xFF5A7A94),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Layer toggles
                  Positioned(
                    bottom: 150,
                    left: 20,
                    right: 20,
                    child: LayerToggles(
                      activeLayer: _activeLayer,
                      onLayerChanged: (layer) => setState(() => _activeLayer = layer),
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
