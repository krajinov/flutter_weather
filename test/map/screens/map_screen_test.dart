import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/home/providers/location_provider.dart';
import 'package:flutter_weather/home/providers/weather_provider.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';
import 'package:flutter_weather/map/screens/map_screen.dart';

void main() {
  testWidgets('keeps map search available when location and weather fail', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          locationProvider.overrideWith((ref) async {
            throw Exception('location unavailable');
          }),
          weatherProvider.overrideWith((ref) async {
            throw Exception('weather unavailable');
          }),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MapScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search city or place'), findsOneWidget);
    expect(find.text('Error loading location'), findsOneWidget);
  });
}
