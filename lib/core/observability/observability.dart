import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show NavigatorObserver;

/// Punto único de entrada a Crashlytics, Analytics y App Check.
///
/// Las pantallas y servicios NO importan los paquetes de Firebase para esto;
/// llaman a [Observability]. Así se puede desactivar, mockear o cambiar de
/// proveedor sin tocar el resto de la app.
///
/// Todos los métodos son seguros de llamar aunque Firebase no haya
/// inicializado (p. ej. en tests o en modo demo): simplemente no hacen nada.
class Observability {
  Observability._();

  static bool _ready = false;
  static FirebaseAnalytics? _analytics;

  /// Llamar una vez tras `Firebase.initializeApp`.
  static Future<void> init() async {
    try {
      // ── App Check ────────────────────────────────────────────────
      // En debug usa el provider de debug (registrar el token impreso en la
      // consola en Firebase Console → App Check). En release usa los
      // atestadores nativos. Empezar en modo "monitor" en la consola y
      // pasar a "enforce" cuando la mayoría del tráfico esté verificado.
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        appleProvider:
            kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
        // Web: reemplazar por la site key de reCAPTCHA v3 del proyecto.
        webProvider:
            kIsWeb ? ReCaptchaV3Provider('RECAPTCHA_V3_SITE_KEY') : null,
      );
    } catch (e) {
      debugPrint('App Check no disponible: $e');
    }

    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(!kDebugMode);
    } catch (e) {
      debugPrint('Analytics no disponible: $e');
    }

    if (!kIsWeb) {
      try {
        final crashlytics = FirebaseCrashlytics.instance;
        await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
        // Errores de Flutter (build, layout, etc.)
        FlutterError.onError = (details) {
          FlutterError.presentError(details);
          crashlytics.recordFlutterFatalError(details);
        };
        // Errores asíncronos fuera de Flutter
        PlatformDispatcher.instance.onError = (error, stack) {
          crashlytics.recordError(error, stack, fatal: true);
          return true;
        };
      } catch (e) {
        debugPrint('Crashlytics no disponible: $e');
      }
    }

    _ready = true;
  }

  /// Asocia los reportes al usuario (sin datos personales: solo uid).
  static Future<void> setUser(String? uid) async {
    if (!_ready) return;
    try {
      await _analytics?.setUserId(id: uid);
      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setUserIdentifier(uid ?? '');
      }
    } catch (_) {}
  }

  /// Evento de producto. Nombres canónicos en la skill `observability`.
  static Future<void> logEvent(
    String name, [
    Map<String, Object>? parameters,
  ]) async {
    if (!_ready) return;
    try {
      await _analytics?.logEvent(name: name, parameters: parameters);
    } catch (_) {}
  }

  static Future<void> logScreen(String screenName) async {
    if (!_ready) return;
    try {
      await _analytics?.logScreenView(screenName: screenName);
    } catch (_) {}
  }

  /// Error capturado que NO tumbó la app (fallo de red, parseo, etc.).
  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    debugPrint('⚠️ ${reason ?? 'error'}: $error');
    if (!_ready || kIsWeb) return;
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason,
        fatal: fatal,
      );
    } catch (_) {}
  }

  /// Observer para que Analytics registre pantallas automáticamente con
  /// `Navigator`. Añadir a `MaterialApp(navigatorObservers: [...])`.
  static List<NavigatorObserver> get navigatorObservers => _analytics == null
      ? const []
      : [FirebaseAnalyticsObserver(analytics: _analytics!)];
}
