import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A place suggestion returned by the geocoding search.
class PlaceSuggestion {
  final String displayName;
  final double latitude;
  final double longitude;
  final String category;
  final String type;

  PlaceSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.type,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    // Build a readable display name from the available properties
    final parts = <String>[];
    if (properties['name'] != null) parts.add(properties['name'] as String);
    if (properties['city'] != null &&
        properties['city'] != properties['name']) {
      parts.add(properties['city'] as String);
    }
    if (properties['county'] != null) parts.add(properties['county'] as String);
    if (properties['state'] != null) parts.add(properties['state'] as String);
    if (properties['country'] != null) {
      parts.add(properties['country'] as String);
    }

    return PlaceSuggestion(
      displayName: parts.isNotEmpty ? parts.join(', ') : 'Unknown Place',
      longitude: (coordinates[0] as num).toDouble(),
      latitude: (coordinates[1] as num).toDouble(),
      category: properties['osm_key'] as String? ?? '',
      type: properties['osm_value'] as String? ?? '',
    );
  }

  /// Unique key for deduplication (based on rounded coordinates).
  String get _dedupeKey =>
      '${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}';
}

/// Service for querying the Photon geocoding API (based on OSM data).
///
/// Photon is specifically designed for search-as-you-type (autocomplete)
/// and handles partial matches (e.g., "Tomislavg" -> "Tomislavgrad") much
/// better than raw Nominatim. It also natively supports location biasing.
class NominatimService {
  static const _baseUrl = 'https://photon.komoot.io/api/';

  /// Search for places matching [query].
  Future<List<PlaceSuggestion>> searchPlaces(
    String query, {
    double? biasLat,
    double? biasLon,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final queryParams = <String, String>{
      'q': trimmed,
      'limit': '15', // Request a bit more to filter down later
    };

    if (biasLat != null && biasLon != null) {
      queryParams['lat'] = biasLat.toString();
      queryParams['lon'] = biasLon.toString();
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'FlutterWeatherApp_Redesign_Autocomplete_v4',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>;

        final results = features
            .map((e) => PlaceSuggestion.fromJson(e as Map<String, dynamic>))
            .toList();

        // Deduplicate
        final seen = <String>{};
        final uniqueResults = <PlaceSuggestion>[];
        for (var s in results) {
          if (seen.add(s._dedupeKey)) {
            uniqueResults.add(s);
          }
        }

        // Keep 'place' and 'boundary' categories at the top (cities, towns, etc.)
        uniqueResults.sort((a, b) {
          final aIsPlace = a.category == 'place' || a.category == 'boundary';
          final bIsPlace = b.category == 'place' || b.category == 'boundary';

          if (aIsPlace && !bIsPlace) return -1;
          if (!aIsPlace && bIsPlace) return 1;
          return 0; // Maintain API's internal relevance/distance ordering for the rest
        });

        debugPrint(
          '[PhotonSearch] "$trimmed": ${uniqueResults.length} results returned',
        );
        return uniqueResults.take(10).toList();
      }

      debugPrint('[PhotonSearch] HTTP ${response.statusCode} for "$trimmed"');
      return [];
    } catch (e) {
      debugPrint('[PhotonSearch] Error: $e');
      return [];
    }
  }
}
