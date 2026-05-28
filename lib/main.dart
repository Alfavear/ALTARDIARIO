import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart'; // Correcto
import 'core/services/notification_service.dart'; // Correcto
import 'data/services/storage_service.dart'; // Correcto
import 'presentation/providers/app_providers.dart';
import 'presentation/screens/main_navigation_view.dart';
import 'presentation/screens/login_screen.dart';
// Si el archivo no existe, debes ejecutar 'flutterfire configure'
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint("Error al inicializar Firebase: $e");
    debugPrint(stack.toString());
    // Podrías mostrar una pantalla de error aquí si Firebase es vital
  }

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  
  try {
    await storageService.loadPlan();
  } catch (e) {
    debugPrint("Error al cargar el plan de lectura: $e");
  }
  
  await NotificationService.init();
  await NotificationService.requestPermissions();
  await NotificationService.scheduleDailyReminder();
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
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'altarDiario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) => user != null ? const MainNavigationView() : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => const LoginScreen(),
      ),
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