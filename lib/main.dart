import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'data/services/storage_service.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("⚠️ Advertencia: Error al inicializar Firebase: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  try {
    await storageService.loadPlan();
  } catch (e) {
    debugPrint("Error al cargar el plan de lectura: $e");
  }

  try {
    await NotificationService.init();
    await NotificationService.requestPermissions();
    await NotificationService.scheduleDailyReminder(
      hour: storageService.getNotificationHour(),
      minute: storageService.getNotificationMinute(),
    );
  } catch (e) {
    debugPrint("Servicio de notificaciones no disponible: $e");
  }
  await initializeDateFormatting('es', null);

  runApp(
    ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(storageService),
      ],
      child: const AltarDiarioApp(),
    ),
  );
}

class AltarDiarioApp extends ConsumerWidget {
  const AltarDiarioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'altarDiario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      builder: (context, child) {
        return MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    );
  }
}
