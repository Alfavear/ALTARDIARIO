import 'dart:async';
import 'dart:convert' show base64UrlEncode, utf8;
import 'dart:math' show Random;

import 'package:crypto/crypto.dart' show sha256;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;

  AuthService() : _auth = _initAuth() {
    if (!kIsWeb) {
      _googleSignIn = GoogleSignIn();
    }
  }

  static FirebaseAuth? _initAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  bool get _firebaseAvailable => _auth != null;

  Stream<User?> get userChanges {
    if (!_firebaseAvailable) return const Stream.empty();
    return _auth!.userChanges();
  }

  User? get currentUser => _firebaseAvailable ? _auth!.currentUser : null;

  static const String _localUidKey = 'local_user_uid';

  Future<String?> getLocalUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localUidKey);
  }

  /// Guarda el UID del último usuario autenticado para poder
  /// entrar sin internet (la sesión de Firebase Auth no se
  /// restaura si no hay red).
  Future<void> persistLocalUid(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localUidKey, uid);
    } catch (_) {}
  }

  Future<String> signInLocal() async {
    final prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString(_localUidKey);
    if (uid == null) {
      uid =
          'demo_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
      await prefs.setString(_localUidKey, uid);
    }
    return uid;
  }

  Future<void> clearLocalUid() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localUidKey);
  }

  Future<User?> signInAnon() async {
    if (!_firebaseAvailable) {
      await signInLocal();
      return null;
    }
    try {
      final result = await _auth!.signInAnonymously();
      if (result.user != null) {
        await persistLocalUid(result.user!.uid);
      }
      return result.user;
    } catch (e) {
      if (kIsWeb) {
        await signInLocal();
        return null;
      }
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    if (!_firebaseAvailable) return null;

    if (kIsWeb) {
      // WEB: Usar Firebase Auth directamente con signInWithPopup
      try {
        debugPrint('🔐 [AuthService] Iniciando signInWithPopup Google...');
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        
        final UserCredential userCredential = 
            await _auth!.signInWithPopup(provider);
        debugPrint('✅ [AuthService] signInWithPopup exitoso: ${userCredential.user?.uid}');
        
        // Verificación defensiva
        if (userCredential.user == null) {
          debugPrint('⚠️ [AuthService] userCredential.user es null');
          return null;
        }
        await persistLocalUid(userCredential.user!.uid);
        return userCredential.user;
      } on FirebaseAuthException catch (e) {
        debugPrint('❌ [AuthService] FirebaseAuthException signInWithPopup: ${e.code} - ${e.message}');
        // Si falla popup (bloqueado), intentar redirect
        if (e.code == 'auth/popup-blocked' || e.code == 'auth/cancelled-popup-request') {
          try {
            debugPrint('🔄 [AuthService] Intentando signInWithRedirect...');
            final provider = GoogleAuthProvider();
            provider.addScope('email');
            provider.addScope('profile');
            await _auth!.signInWithRedirect(provider);
            debugPrint('✅ [AuthService] signInWithRedirect iniciado');
            return null;
          } catch (e2) {
            debugPrint('❌ [AuthService] Error signInWithRedirect: $e2');
            return null;
          }
        }
        rethrow;
      } catch (e) {
        debugPrint('❌ [AuthService] Error genérico signInWithPopup: $e');
        // Si falla popup (bloqueado), intentar redirect
        try {
          debugPrint('🔄 [AuthService] Intentando signInWithRedirect...');
          final provider = GoogleAuthProvider();
          provider.addScope('email');
          provider.addScope('profile');
          await _auth!.signInWithRedirect(provider);
          debugPrint('✅ [AuthService] signInWithRedirect iniciado');
          return null;
        } catch (e2) {
          debugPrint('❌ [AuthService] Error signInWithRedirect: $e2');
          return null;
        }
      }
    } else {
      // MOBILE (Android/iOS): Usar google_sign_in package
      try {
        debugPrint('🔐 [AuthService] Iniciando Google Sign-In mobile...');
        final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
        if (googleUser == null) {
          debugPrint('⚠️ [AuthService] Usuario canceló Google Sign-In');
          return null;
        }
        
        final GoogleSignInAuthentication googleAuth = 
            await googleUser.authentication;
        
        final String? accessToken = googleAuth.accessToken;
        final String? idToken = googleAuth.idToken;
        
        if (accessToken == null || idToken == null) {
          debugPrint('⚠️ [AuthService] Tokens null: accessToken=$accessToken, idToken=$idToken');
          return null;
        }
        
        final credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken,
        );
        
        final UserCredential userCredential = 
            await _auth!.signInWithCredential(credential);
        debugPrint('✅ [AuthService] Google Sign-In mobile exitoso: ${userCredential.user?.uid}');
        if (userCredential.user != null) {
          await persistLocalUid(userCredential.user!.uid);
        }
        return userCredential.user;
      } catch (e) {
        debugPrint('❌ [AuthService] Error Google Sign-In mobile: $e');
        return null;
      }
    }
  }

  /// Maneja el resultado de signInWithRedirect (web)
  Future<User?> handleRedirectResult() async {
    if (!_firebaseAvailable || !kIsWeb) return null;
    try {
      debugPrint('🔄 [AuthService] Verificando redirect result...');
      final UserCredential result = 
          await _auth!.getRedirectResult();
      debugPrint('✅ [AuthService] Redirect result: ${result.user?.uid ?? "null"}');
      
      if (result.user != null) {
        await persistLocalUid(result.user!.uid);
        return result.user;
      }
      return null;
    } catch (e) {
      debugPrint('❌ [AuthService] Error handleRedirectResult: $e');
      return null;
    }
  }

  Future<User?> signInWithApple() async {
    if (!_firebaseAvailable) return null;
    if (kIsWeb) return null; // Apple Sign-In no soportado en web por este package
    
    final rawNonce = _generateNonce();
    final nonce = _sha256OfString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final UserCredential userCredential =
        await _auth!.signInWithCredential(credential);
    if (userCredential.user != null) {
      await persistLocalUid(userCredential.user!.uid);
    }
    return userCredential.user;
  }

  String _generateNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes);
  }

  Future<void> signOut() async {
    if (!_firebaseAvailable) {
      await clearLocalUid();
      return;
    }
    if (!kIsWeb && _googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
    await _auth!.signOut();
    await clearLocalUid();
  }

  /// Guarda el token FCM del usuario en Firestore
  Future<void> saveFCMToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set(
          {'fcmToken': token},
          SetOptions(merge: true),
        );
        debugPrint('FCM Token guardado para $uid');
      }
    } catch (e) {
      debugPrint('Error guardando FCM token: $e');
    }
  }
}