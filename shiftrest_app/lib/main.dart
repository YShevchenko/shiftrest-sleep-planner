import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/sqlite_shift_repository.dart';
import 'data/repositories/sqlite_sleep_repository.dart';
import 'domain/repositories/shift_repository.dart';
import 'domain/repositories/sleep_repository.dart';
import 'domain/services/alarm_service.dart';
import 'domain/services/sleep_calculator.dart';
import 'domain/services/noise_service.dart';
import 'presentation/providers/shift_provider.dart';
import 'presentation/providers/sleep_plan_provider.dart';
import 'presentation/providers/dark_room_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'services/iap_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar style for dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  // Initialize repositories
  final shiftRepository = SqliteShiftRepository();
  final sleepRepository = SqliteSleepRepository();
  final sleepCalculator = const SleepCalculator();
  final noiseService = NoiseService();
  final alarmService = AlarmService();
  await alarmService.initialize();

  // Load settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  // Initialize IAP service
  final iapService = IapService();
  await iapService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ShiftProvider(shiftRepository, alarmService),
        ),
        ChangeNotifierProvider(
          create: (_) => SleepPlanProvider(sleepRepository, sleepCalculator),
        ),
        ChangeNotifierProvider(
          create: (_) => DarkRoomProvider(noiseService),
        ),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: iapService),
        Provider<ShiftRepository>.value(value: shiftRepository),
        Provider<SleepRepository>.value(value: sleepRepository),
        Provider<NoiseService>.value(value: noiseService),
        Provider<AlarmService>.value(value: alarmService),
      ],
      child: const ShiftRestApp(),
    ),
  );
}
