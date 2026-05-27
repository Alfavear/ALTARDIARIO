import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  Future<User?> signInWithGoogle() async {
    // Iniciar el flujo de autenticación de Google
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // El usuario canceló

    // Obtener detalles de autenticación de la petición
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Crear una nueva credencial
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Una vez logueado, devolver el UserCredential
    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
