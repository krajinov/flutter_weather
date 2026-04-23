import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

Widget localizedPreview(Widget child, {bool useProviderScope = false}) {
  Widget content = MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    debugShowCheckedModeBanner: false,
    home: child,
  );

  if (useProviderScope) {
    content = ProviderScope(child: content);
  }

  return content;
}
