import 'package:flutter/material.dart' show Color;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:firebase_messaging/firebase_messaging.dart';

/// Servicio de notificaciones (locales + FCM push) para recordatorios diarios de lectura.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static bool _initialized = false;
  static bool _fcmInitialized = false;

  /// Inicializa el plugin de notificaciones locales y FCM.
  static Future<void> init() async {
    if (kIsWeb || _initialized) return;

    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // El usuario tocó la notificación — se podría navegar al calendario.
      },
    );

    _initialized = true;
    await _initFCM();
  }

  /// Inicializa Firebase Cloud Messaging para push notifications.
  static Future<void> _initFCM() async {
    if (kIsWeb || _fcmInitialized) return;

    // Solicitar permisos
    final NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('FCM: Permisos no concedidos');
      return;
    }

    // Obtener token FCM
    final String? token = await _fcm.getToken();
    debugPrint('FCM Token: $token');

    _fcmInitialized = true;

    // Manejar mensajes en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Manejar mensajes cuando app está en background pero abierta
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Manejar mensajes cuando app está terminada y se abre desde notificación
    final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      // TODO: Actualizar token en Firestore via callback
      _onTokenRefresh?.call(newToken);
    });
  }

  /// Callback opcional para cuando se refresca el token FCM
  static void Function(String)? _onTokenRefresh;

  /// Registra callback para cuando se refresca el token FCM
  static void setOnTokenRefresh(void Function(String) callback) {
    _onTokenRefresh = callback;
  }

  /// Obtiene el token FCM actual (útil para guardar en Firestore tras login).
  static Future<String?> getFCMToken() async {
    if (kIsWeb || !_fcmInitialized) return null;
    return await _fcm.getToken();
  }

  /// Maneja mensajes recibidos con la app en primer plano.
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM Foreground: ${message.notification?.title}');
    _showLocalNotification(
      title: message.notification?.title ?? 'altarDiario',
      body: message.notification?.body ?? 'Tienes un nuevo mensaje',
      payload: message.data,
    );
  }

  /// Maneja cuando el usuario toca una notificación (app en background/terminada).
  static void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('FCM Opened App: ${message.notification?.title}');
    // TODO: Navegar según message.data['route'] o tipo de notificación
  }

  /// Muestra una notificación local inmediata (para mensajes FCM en foreground).
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    if (kIsWeb || !_initialized) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'altar_diario_fcm',
      'Notificaciones Push',
      channelDescription: 'Notificaciones push de altarDiario',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF1565C0),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload?.toString(),
    );
  }

  /// Muestra una notificación local inmediata (para insignias o logros).
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !_initialized) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'altar_diario_badges',
      'Insignias y Logros',
      channelDescription: 'Notificaciones de nuevas insignias desbloqueadas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF1565C0),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id,
      title,
      body,
      details,
    );
  }

  /// Solicita permisos de notificación (necesario en Android 13+ e iOS).
  static Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    // Android
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS
    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Programa un recordatorio diario a la hora configurada.
  static Future<void> scheduleDailyReminder({
    int hour = 20,
    int minute = 0,
  }) async {
    if (kIsWeb) return;

    await _plugin.cancelAll();

    final tz.TZDateTime scheduledDate = _nextInstanceOf(hour, minute);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'altar_diario_reminder',
      'Recordatorio Diario',
      channelDescription: 'Recordatorio para completar tu lectura bíblica diaria',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF1565C0),
      styleInformation: BigTextStyleInformation(
        '¡No olvides tu lectura de hoy! Mantén tu racha activa 🔥',
        contentTitle: '📖 altarDiario',
        summaryText: 'Tu hábito diario con Dios',
      ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      0,
      '📖 altarDiario',
      '¡No olvides tu lectura de hoy! Mantén tu racha activa 🔥',
      scheduledDate,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Calcula la próxima instancia de la hora especificada.
  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Cancela todas las notificaciones programadas.
  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
