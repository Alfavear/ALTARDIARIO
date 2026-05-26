import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para escuchar cambios de autenticación
  Stream<User?> get userChanges => _auth.userChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Iniciar sesión anónima
  Future<User?> signInAnon() async {
    final result = await _auth.signInAnonymously();
    return result.user;
  }

  // Iniciar sesión con Google
  // (Requiere configuración adicional en Android/iOS)
  // Future<User?> signInWithGoogle() async { ... }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
