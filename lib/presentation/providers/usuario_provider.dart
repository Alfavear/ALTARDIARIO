import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/usuario.dart'; // Correcto

/// Notifier para gestionar el estado del usuario en Riverpod 3.0.
class UsuarioNotifier extends Notifier<Usuario?> {
  @override
  Usuario? build() => null;

  void update(Usuario? user) => state = user;
}

/// Proveedor para gestionar el estado del usuario actual.
final usuarioProvider = NotifierProvider<UsuarioNotifier, Usuario?>(UsuarioNotifier.new);
