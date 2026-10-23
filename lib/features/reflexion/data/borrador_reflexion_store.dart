import 'package:shared_preferences/shared_preferences.dart';

/// Borrador de una reflexión que el usuario está escribiendo.
class BorradorReflexion {
  final String texto;
  final String pasaje;

  const BorradorReflexion({required this.texto, required this.pasaje});

  bool get vacio => texto.trim().isEmpty;
}

/// Guarda el borrador de la reflexión en el almacenamiento local.
///
/// Sirve para que cerrar la app —o que el sistema la mate mientras se escribe—
/// no borre lo que el usuario llevaba escrito. La pantalla guarda con un
/// pequeño retardo para no escribir en cada pulsación.
class BorradorReflexionStore {
  static const claveTexto = 'borrador_reflexion_texto';
  static const clavePasaje = 'borrador_reflexion_pasaje';

  Future<void> guardar(BorradorReflexion borrador) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(claveTexto, borrador.texto);
    await prefs.setString(clavePasaje, borrador.pasaje);
  }

  Future<BorradorReflexion?> leer() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(claveTexto);
    if (texto == null || texto.trim().isEmpty) return null;
    return BorradorReflexion(
      texto: texto,
      pasaje: prefs.getString(clavePasaje) ?? '',
    );
  }

  Future<void> borrar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(claveTexto);
    await prefs.remove(clavePasaje);
  }
}
