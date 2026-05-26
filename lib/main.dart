
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'views/main_navigation_view.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar locale español para DateFormat
  await initializeDateFormatting('es', null);

  // Inicializar servicios
  final storageService = StorageService();
  await storageService.init();

  // Inicializar notificaciones
  await NotificationService.init();
  await NotificationService.requestPermissions();
  await NotificationService.scheduleDailyReminder();

  // Configurar barra de estado transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    ProviderScope(
      child: AltarDiarioApp(storageService: storageService),
    ),
  );
}

class AltarDiarioApp extends StatelessWidget {
  final StorageService storageService;

  const AltarDiarioApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'altarDiario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainNavigationView(storageService: storageService),
    );
  }
}
