import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/observability/observability.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/storage_service.dart';
import 'firebase_options.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Observability.init();
  } catch (e) {
    debugPrint('⚠️ Advertencia: Error al inicializar Firebase: $e');
  }

  // Web: Manejar resultado de signInWithRedirect (Google OAuth)
  if (kIsWeb) {
    try {
      final authService = AuthService();
      await authService
          .handleRedirectResult()
          .timeout(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Redirect result handling: $e');
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  try {
    await storageService.loadPlan();
  } catch (e) {
    debugPrint('Error al cargar el plan de lectura: $e');
  }

  try {
    await NotificationService.init();
    await NotificationService.requestPermissions();
    await NotificationService.scheduleDailyReminder(
      hour: storageService.getNotificationHour(),
      minute: storageService.getNotificationMinute(),
    );
  } catch (e) {
    debugPrint('Servicio de notificaciones no disponible: $e');
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
      navigatorObservers: Observability.navigatorObservers,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}
