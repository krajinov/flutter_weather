import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';
import 'core/services/background_weather_scheduler.dart';
import 'core/services/local_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'home/providers/navigation_provider.dart';
import 'home/screens/home_screen.dart';
import 'settings/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env", isOptional: true);
  final initialNotificationPayload = await LocalNotificationService.instance
      .initialize();
  await BackgroundWeatherScheduler.initialize();

  runApp(
    ProviderScope(
      child: WeatherApp(initialNotificationPayload: initialNotificationPayload),
    ),
  );
}

class WeatherApp extends ConsumerStatefulWidget {
  final String? initialNotificationPayload;

  const WeatherApp({super.key, this.initialNotificationPayload});

  @override
  ConsumerState<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends ConsumerState<WeatherApp> {
  StreamSubscription<String?>? _notificationTapSubscription;

  @override
  void initState() {
    super.initState();
    if (LocalNotificationService.opensAlerts(
      widget.initialNotificationPayload,
    )) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedTabProvider.notifier).showAlerts();
      });
    }

    _notificationTapSubscription = LocalNotificationService
        .instance
        .notificationTapStream
        .listen((payload) {
          if (!LocalNotificationService.opensAlerts(payload)) return;
          ref.read(selectedTabProvider.notifier).showAlerts();
        });
  }

  @override
  void dispose() {
    _notificationTapSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider).value;

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings?.themeMode ?? ThemeMode.dark,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
