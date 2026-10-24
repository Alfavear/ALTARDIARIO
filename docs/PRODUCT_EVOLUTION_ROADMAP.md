# Roadmap funcional y de producto

Última actualización: 2026-10-20.

Este documento guía la evolución de AltarDiario para agentes y equipo de
producto. Complementa `roadmap/tasks.yaml`, que sigue siendo el backlog
operativo y solo debe modificarse mediante el MCP `roadmap`.

## Objetivo de producto

Convertir AltarDiario en un hábito devocional diario que sea privado por
defecto, seguro al relacionarse con otras personas y sencillo de usar con una
mano. Cada mejora debe favorecer una de estas metas:

1. Completar la lectura y reflexión del día.
2. Pedir, ofrecer y dar seguimiento a oración de forma segura.
3. Construir comunidad sin exponer datos privados ni tolerar abuso.
4. Mantener la aplicación rápida y accesible en equipos modestos.

## Cómo continuar este roadmap

Antes de empezar una unidad, crear la tarea equivalente en el MCP roadmap y
registrar el ciclo. Cada unidad se entrega en un PR pequeño, con sus pruebas,
`CHANGELOG.md` y `scripts/check.sh --fast`. Si modifica `firestore.rules`,
también ejecutar `scripts/rules_test.sh`.

No agrupar una fase completa en un único PR. Las dependencias de seguridad
preceden a la UI que las expone.

## Fase 0 — Integrar la auditoría actual

**Resultado esperado:** las correcciones ya creadas llegan a `main` sin
perder sus controles de seguridad.

| Orden | Entrega | Dependencia | Criterio de aceptación |
| --- | --- | --- | --- |
| 0.1 | Fusionar PR #20: límites y escala de texto. | CI de #20. | Los streams quedan limitados y el tamaño de texto respeta el sistema. |
| 0.2 | Fusionar PR #21: perfil privado. | #20. | Perfiles nuevos no guardan correo ni FCM en el documento público. |
| 0.3 | Fusionar PR #22: reporte de perfiles. | #21. | Un usuario autenticado puede reportar otro perfil con motivo válido. |
| 0.4 | Migración administrativa de privacidad. | #21 fusionado. | Correos y tokens antiguos se mueven a `private/account`, se auditan cantidades y se verifica una muestra. |

**Riesgo que no se debe ignorar:** hasta completar 0.4, perfiles históricos
pueden conservar datos privados en documentos que aún se leen públicamente.

## Fase 1 — Seguridad y comunidad sana

### 1.1 Bloquear usuarios

**Problema:** reportar ayuda a moderación, pero una persona no puede cortar el
contacto con un usuario abusivo.

**Experiencia:** desde un perfil, menú de contenido y chat, mostrar
`Bloquear usuario`. La confirmación explica que se ocultarán publicaciones,
comentarios, perfiles, notificaciones y mensajes de esa persona. Debe existir
`Usuarios bloqueados` en Ajustes para desbloquear.

**Criterios de aceptación:**

- La lista de bloqueados es privada para el dueño.
- Feed, peticiones, debates, comentarios, perfiles, seguidores, sugerencias,
  notificaciones y chats no muestran cuentas bloqueadas.
- No se puede iniciar ni continuar un chat con una cuenta bloqueada.
- Las reglas impiden leer o modificar los bloqueos ajenos.
- Hay pruebas de reglas, servicio, providers y estado vacío de UI.

**División sugerida:** datos y reglas; filtros de contenido social; chat y
notificaciones; ajustes y desbloqueo.

### 1.2 Reportar contenido en cada superficie

**Experiencia:** menú de tres puntos en reflexiones, comentarios, peticiones,
debates y respuestas. Reutilizar los motivos de perfil y añadir, si producto
lo aprueba, `Información engañosa`.

**Criterios de aceptación:**

- Cada reporte escribe únicamente los cinco campos permitidos por la allowlist
  de `/reports`.
- La Function registra y marca como `oculto` el contenido con tres reportantes
  distintos.
- La app no muestra contenido `oculto` y el autor no puede eludirlo editando
  el campo.
- Se cubre cada `targetType` de la Function con pruebas de reglas y Function.

### 1.3 Eliminación de cuenta y controles de privacidad

**Experiencia:** en Perfil → Cuenta, opción visible `Eliminar mi cuenta`,
confirmación de doble paso y una página que explique los datos que se borran.

**Criterios de aceptación:**

- Una Cloud Function administrativa elimina Auth, perfil, subcolecciones,
  mensajes, reflexiones, comentarios, peticiones y debates del usuario.
- El cliente no recibe privilegios administrativos.
- La operación es idempotente, registra solo UID y resultado, y muestra un
  estado claro al usuario.
- Se documenta recuperación de autenticación reciente si Firebase la exige.

## Fase 2 — Hábito devocional diario

### 2.1 Inicio centrado en "Hoy"

**Experiencia:** reemplazar la competencia entre tarjetas por una cabecera
simple: progreso de lectura, pasaje actual, CTA `Continuar lectura` y CTA
secundario `Escribir reflexión`. La racha aparece como refuerzo, no como
bloqueador.

**Criterios de aceptación:**

- En menos de dos toques se abre la lectura pendiente.
- Si el día está completo, se muestra una celebración discreta y la siguiente
  lectura disponible.
- Skeleton de carga, estado offline y escalado de texto accesible.
- Widget test para pendiente, completado y sin conexión.

### 2.2 Reflexión guiada y privada por defecto

**Experiencia:** al terminar una lectura, ofrecer tres disparadores breves:
`¿Qué aprendí?`, `¿Qué pondré en práctica?`, `¿Por quién voy a orar?`. Por
defecto se guarda como nota privada; publicar en comunidad debe ser una acción
explícita con una vista previa.

**Criterios de aceptación:**

- Borrador local recuperable tras cerrar la app.
- Publicación exige confirmación y aplica la política comunitaria.
- El usuario puede convertir su nota en publicación sin copiar texto.
- No se eleva el límite de texto sin revisar coste y moderación.

### 2.3 Oración con seguimiento

**Experiencia:** una petición puede marcarse como `respondida`, añadir una
actualización del autor y permitir que quien la apoyó reciba un aviso
configurable. El feed ofrece filtros `Recientes`, `Por las que oro` y
`Respondidas`.

**Criterios de aceptación:**

- Solo el autor cambia el estado de respuesta.
- La notificación es opcional y no expone el contenido privado en pantalla de
  bloqueo.
- Las consultas tienen índice, límite y paginación.

## Fase 3 — Comunidad útil y controlada

### 3.1 Feed con paginación real

**Experiencia:** carga inicial breve, botón o scroll de `Cargar más`, indicador
de progreso y opción de reintentar. Mantener el orden estable por fecha.

**Criterios de aceptación:**

- Usa cursores `startAfterDocument`, no aumenta el límite indefinidamente.
- No duplica ni salta elementos al cargar una página.
- Respeta bloqueos y contenido oculto en cada página.
- Pruebas de servicio para cursor, final de lista y error.

### 3.2 Descubrimiento sin ruido

**Experiencia:** búsqueda por pasaje, tema y autor; chips de temas seguidos;
orden `Reciente` y `Más acompañadas`. No introducir ranking opaco ni
notificaciones agresivas.

**Criterios de aceptación:**

- La búsqueda tiene mínimo de caracteres, debounce y límites de consulta.
- Los resultados no enseñan usuarios bloqueados ni contenido oculto.
- Se registran eventos analíticos sin texto de la publicación ni datos
personales.

### 3.3 Debate bíblico de calidad

**Experiencia:** etiquetas de libro, cita y contexto; respuestas anidadas como
máximo a un nivel; acciones de reportar y bloquear siempre visibles.

**Criterios de aceptación:**

- Cada consulta está indexada, limitada y paginada.
- El autor puede cerrar un debate; moderación puede ocultarlo.
- La UI muestra reglas comunitarias antes de la primera publicación.

## Fase 4 — Personalización y accesibilidad

### 4.1 Ajustes de lectura

**Experiencia:** selector de traducción, tamaño de letra, espaciado y modo de
alto contraste. Los ajustes se aplican inmediatamente y se conservan por
dispositivo.

**Criterios de aceptación:**

- No se anula `MediaQuery.textScaler`.
- Todos los controles se pueden usar con lector de pantalla y teclado web.
- Contraste y áreas táctiles cumplen Material 3.

### 4.2 Biblioteca personal

**Experiencia:** vista única de resaltados, notas y reflexiones privadas con
filtro por libro, etiqueta y fecha; exportación de texto solicitada por el
usuario.

**Criterios de aceptación:**

- Los datos permanecen privados en Firestore y almacenamiento local.
- La exportación no se envía a terceros automáticamente.
- Los estados vacío y offline orientan sin bloquear la lectura.

### 4.3 Notificaciones con intención

**Experiencia:** preferencias separadas para lectura, oración, comunidad y
racha; horario tranquilo; resumen semanal opcional.

**Criterios de aceptación:**

- El usuario controla cada categoría y puede desactivarla sin perder datos.
- FCM y preferencias se mantienen en el documento privado de cuenta.
- Las notificaciones no incluyen el texto sensible de peticiones de oración.

## Fase 5 — Calidad técnica sostenible

### 5.1 Migración feature-first

Migrar una feature por PR desde `lib/presentation/` y
`lib/presentation/providers/app_providers.dart` a `lib/features/<feature>/`.
Empezar por moderación, por ser nueva y pequeña; seguir con oración y feed.

### 5.2 Observabilidad accionable

Añadir eventos para completar lectura, guardar nota, publicar reflexión,
reportar y bloquear. Nunca enviar textos, correos, tokens ni motivos libres a
Analytics o Crashlytics.

### 5.3 Rendimiento y resiliencia

Medir tiempo de primer contenido, errores de Firestore y tamaño de consultas.
Priorizar caché offline de Biblia, paginación y reintentos explícitos antes de
añadir dependencias.

## Secuencia sugerida de las próximas diez tareas MCP

1. Ejecutar y verificar la migración administrativa de privacidad.
2. Diseñar datos y reglas de bloqueo de usuarios.
3. Filtrar bloqueos en feed, oración y debate.
4. Filtrar bloqueos en chats y notificaciones; añadir desbloqueo en Ajustes.
5. Añadir reporte para reflexiones y comentarios.
6. Añadir reporte para peticiones, debates y respuestas; probar la Function.
7. Filtrar contenido `oculto` en todos los providers y pantallas.
8. Implementar eliminación de cuenta en Cloud Function y UI.
9. Añadir paginación por cursor al feed.
10. Rediseñar Inicio con el flujo "Hoy" y sus tres estados principales.

## Indicadores para revisar cada mes

| Área | Indicador | Señal saludable |
| --- | --- | --- |
| Hábito | Lecturas completadas por usuario activo semanal. | Tendencia creciente sin más notificaciones invasivas. |
| Activación | Porcentaje que completa la primera lectura. | Mejora tras simplificar Inicio. |
| Comunidad | Reportes por contenido publicado y tiempo de resolución. | Reporte accesible y volumen estable o descendente. |
| Seguridad | Perfiles con campos privados públicos. | Cero tras la migración. |
| Rendimiento | Documentos leídos por apertura de feed. | Estable al crecer la base de usuarios. |
| Accesibilidad | Incidencias de escala de texto, contraste y foco. | Cero regresiones por versión. |

