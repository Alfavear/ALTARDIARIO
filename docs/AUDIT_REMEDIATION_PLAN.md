# Plan de remediación de auditoría

Este plan convierte los hallazgos de auditoría en cambios pequeños, con una
verificación y un pull request por unidad. No sustituye el backlog del roadmap;
cuando el MCP roadmap esté disponible, sus tareas deben registrarse allí.

## 1. Coste y accesibilidad

Estado: en revisión en PR #20.

- Limitar los streams de colecciones sociales y chats.
- Respetar la escala de texto configurada por el sistema.
- Añadir pruebas de los límites de consulta.

## 2. Privacidad de perfiles

Estado: en curso.

- Guardar correo y token FCM en `usuarios/{uid}/private/account`.
- Impedir que los nuevos perfiles públicos añadan `email` o `fcmToken`.
- Migrar los campos privados de perfiles existentes mediante una operación
  administrativa antes de endurecer las reglas de lectura del perfil público.

## 3. Moderación y controles sociales

Estado: en curso.

- Añadida la acción de reportar perfiles; faltan las acciones para feed,
  peticiones y debates, además del bloqueo.
- Ocultar contenido y contactos bloqueados en consultas y pantallas.
- Probar reglas y función de moderación para cada tipo de reporte.

## 4. Cuenta y cumplimiento de tiendas

Estado: pendiente.

- Crear un flujo de eliminación de cuenta que borre Auth, perfil, datos
  privados y contenido asociado desde una Cloud Function administrativa.
- Mostrar el flujo desde Perfil y documentar su efecto.
- Revisar licencias de las traducciones bíblicas antes de publicar una nueva
  versión.

## 5. Paginación y estructura

Estado: pendiente.

- Añadir paginación por cursor a feed, comentarios, debates y chats.
- Migrar una pantalla o servicio grande por pull request a `lib/features/`.
- Mantener la cobertura de sus estados principales durante cada migración.
