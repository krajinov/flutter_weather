import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/core/services/nominatim_service.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';
import 'package:flutter_weather/map/widgets/floating_search_bar.dart';
import 'package:latlong2/latlong.dart';

void main() {
  testWidgets('ignores stale responses for older queries', (tester) async {
    final service = _FakeNominatimService();

    await tester.pumpWidget(_buildSearchBar(service));

    await tester.enterText(find.byType(TextField), 'Sa');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(find.byType(TextField), 'Sar');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    service.complete('Sar', [_suggestion('Sarajevo, Bosnia and Herzegovina')]);
    await tester.pump();

    expect(find.text('Sarajevo'), findsOneWidget);

    service.complete('Sa', [_suggestion('Salzburg, Austria')]);
    await tester.pump();

    expect(find.text('Sarajevo'), findsOneWidget);
    expect(find.text('Salzburg'), findsNothing);
  });

  testWidgets('keeps cleared searches from reopening suggestions', (
    tester,
  ) async {
    final service = _FakeNominatimService();

    await tester.pumpWidget(_buildSearchBar(service));

    await tester.enterText(find.byType(TextField), 'Sa');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    service.complete('Sa', [_suggestion('Salzburg, Austria')]);
    await tester.pump();

    expect(find.text('Salzburg'), findsNothing);
  });
}

Widget _buildSearchBar(_FakeNominatimService service) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: FloatingSearchBar(
        currentPosition: const LatLng(43.8563, 18.4131),
        onSuggestionSelected: (_) {},
        nominatimService: service,
      ),
    ),
  );
}

PlaceSuggestion _suggestion(String displayName) {
  return PlaceSuggestion(
    displayName: displayName,
    latitude: 43.8563,
    longitude: 18.4131,
    category: 'place',
    type: 'city',
  );
}

class _FakeNominatimService extends NominatimService {
  final Map<String, Completer<List<PlaceSuggestion>>> _completers = {};

  @override
  Future<List<PlaceSuggestion>> searchPlaces(
    String query, {
    double? biasLat,
    double? biasLon,
  }) {
    return _completers
        .putIfAbsent(query, () => Completer<List<PlaceSuggestion>>())
        .future;
  }

  void complete(String query, List<PlaceSuggestion> results) {
    _completers[query]!.complete(results);
  }
}
