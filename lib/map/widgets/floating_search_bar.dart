import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';
import '../../core/services/nominatim_service.dart';
import 'package:latlong2/latlong.dart';

class FloatingSearchBar extends StatefulWidget {
  final LatLng? currentPosition;
  final Function(PlaceSuggestion) onSuggestionSelected;
  final NominatimService nominatimService;

  const FloatingSearchBar({
    super.key,
    this.currentPosition,
    required this.onSuggestionSelected,
    required this.nominatimService,
  });

  @override
  State<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<PlaceSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;
  Timer? _debounceTimer;
  int _activeSearchRequestId = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    final requestId = ++_activeSearchRequestId;
    _debounceTimer?.cancel();

    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(query, requestId);
    });
  }

  Future<void> _fetchSuggestions(String query, int requestId) async {
    if (!mounted || requestId != _activeSearchRequestId) return;
    setState(() => _isSearching = true);

    final results = await widget.nominatimService.searchPlaces(
      query,
      biasLat: widget.currentPosition?.latitude,
      biasLon: widget.currentPosition?.longitude,
    );

    if (!mounted || requestId != _activeSearchRequestId) return;

    setState(() {
      _suggestions = results;
      _showSuggestions = _searchFocusNode.hasFocus && results.isNotEmpty;
      _isSearching = false;
    });
  }

  void _handleSuggestionSelected(PlaceSuggestion suggestion) {
    widget.onSuggestionSelected(suggestion);
    _activeSearchRequestId++;

    setState(() {
      _searchController.removeListener(_onSearchChanged);
      _searchController.text = suggestion.displayName.split(',').first;
      _searchController.addListener(_onSearchChanged);
      _suggestions = [];
      _showSuggestions = false;
      _isSearching = false;
    });

    _searchFocusNode.unfocus();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0x660D1E30),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0x337FA5C8)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchCity,
                  hintStyle: const TextStyle(color: Color(0xFFAFC2D3)),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    color: Color(0xFF7CC4FF),
                  ),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(14.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF7CC4FF),
                          ),
                        )
                      : _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            color: Color(0xFF7CC4FF),
                          ),
                          onPressed: () {
                            _activeSearchRequestId++;
                            _searchController.clear();
                            setState(() {
                              _suggestions = [];
                              _showSuggestions = false;
                              _isSearching = false;
                            });
                            _searchFocusNode.requestFocus();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Suggestions Dropdown
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: const Color(0xE60D1E30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x337FA5C8)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x60000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                        onTap: () => _handleSuggestionSelected(suggestion),
                        splashColor: const Color(0x207CC4FF),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
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
          ),
      ],
    );
  }
}
