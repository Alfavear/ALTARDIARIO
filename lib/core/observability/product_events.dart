import 'observability.dart';

/// Eventos de producto de AltarDiario.
///
/// Regla dura: por aquí **no entra texto libre**. Nada de títulos, contenidos,
/// correos, tokens ni motivos escritos por el usuario; solo números, booleanos
/// y valores de un conjunto cerrado (ver [valoresCerrados]).
enum EventoProducto {
  lecturaCompletada('lectura_completada'),
  notaGuardada('nota_guardada'),
  reflexionPublicada('reflexion_publicada'),
  contenidoReportado('contenido_reportado'),
  usuarioBloqueado('usuario_bloqueado');

  const EventoProducto(this.nombre);

  final String nombre;
}

/// Valores cerrados admitidos como parámetro: son categorías de la app, no
/// texto que escriba el usuario.
const Set<String> valoresCerrados = {
  'lectura',
  'nota',
  'reflexion',
  'comentario',
  'perfil',
  'chat',
  'oracion',
  'debate',
  'spam',
  'acoso',
  'contenido_inapropiado',
  'otro',
  'inicio',
  'feed',
  'ajustes',
  'notificacion',
};

/// Claves admitidas como parámetro. Cualquier otra se ignora.
const Set<String> clavesPermitidas = {
  'origen',
  'tipo',
  'categoria',
  'racha',
  'total_lecturas',
  'longitud_texto',
  'tiene_pasaje',
  'pantalla',
  'exito',
};

/// Deja solo los parámetros que no pueden contener datos personales.
///
/// - Se quedan los números (métricas) y los booleanos.
/// - Se quedan las cadenas que están en [valoresCerrados].
/// - Se descartan las claves fuera de [clavesPermitidas].
/// - Se descarta cualquier otra cadena: textos, correos, tokens y motivos
///   libres nunca llegan a Analytics.
Map<String, Object> sanitizarParametros(Map<String, Object>? parametros) {
  if (parametros == null || parametros.isEmpty) return const {};
  final limpios = <String, Object>{};
  for (final entrada in parametros.entries) {
    if (!clavesPermitidas.contains(entrada.key)) continue;
    final valor = entrada.value;
    if (valor is int || valor is bool || valor is double) {
      limpios[entrada.key] = valor;
    } else if (valor is String && valoresCerrados.contains(valor)) {
      limpios[entrada.key] = valor;
    }
  }
  return limpios;
}

/// Punto único para registrar eventos de producto.
///
/// Nunca lanza: si Analytics no está disponible (tests, modo demo), el evento
/// simplemente no se envía.
class ProductoAnalytics {
  ProductoAnalytics._();

  /// Registra [evento] con los parámetros saneados. Los parámetros con datos
  /// personales se descartan, no se enmascaran.
  static Future<void> registrar(
    EventoProducto evento, {
    Map<String, Object>? parametros,
  }) async {
    final limpios = sanitizarParametros(parametros);
    await Observability.logEvent(
      evento.nombre,
      limpios.isEmpty ? null : limpios,
    );
  }
}
