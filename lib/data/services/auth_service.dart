import 'dart:async';
import 'dart:convert' show base64UrlEncode, utf8;
import 'dart:math' show Random;

import 'package:crypto/crypto.dart' show sha256;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth? _auth;

  AuthService() : _auth = _initAuth();

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
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential =
        await _auth!.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<User?> signInWithApple() async {
    if (!_firebaseAvailable) return null;
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
    if (!_firebaseAvailable) return;
    await _auth!.signOut();
  }
}
