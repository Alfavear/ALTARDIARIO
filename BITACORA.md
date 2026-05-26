## 2026-05-27 (Navegación Global)

- **Implementación de MainNavigationView**: Se crea el contenedor principal con `BottomNavigationBar` para alternar entre Calendario, Feed, Oración y Perfil.
- **Uso de IndexedStack**: Se utiliza para mantener el estado de las pantallas al navegar (por ejemplo, que el calendario no pierda el scroll al ir al feed).
- **Placeholders**: Se crean las estructuras base para `OracionScreen` y `PerfilScreen`.
- **Siguiente paso**: Iniciar la **Fase 2** con las interacciones del Feed (Likes y comentarios).

## 2026-05-27 (Planificación Estratégica)

- **Definición de RoadMap**: Se establece un plan de 5 fases para transformar la app en red social.
- **Integración de Flujo Devocional**: Se modifica `CalendarioView` para redirigir automáticamente a `PublicarReflexionScreen` tras marcar una lectura.
- **Estructuración de Tareas**: Priorización de navegación global y sistema de oraciones para las próximas sesiones.
- **Siguiente paso**: Crear el `MainNavigationView` que servirá de contenedor para todas las nuevas secciones (Feed, Oración, Perfil).

## 2026-05-27 (continuación)

- **Implementación de Pantallas Sociales**: Se crean `PublicarReflexionScreen.dart` y `FeedScreen.dart`.
- **Integración en Tiempo Real**: Se utiliza `reflexionesStreamProvider` de Riverpod para actualizar el feed automáticamente cuando alguien publica.
- **Lógica de Publicación**: Conectado el formulario de reflexiones con `FirestoreService` y manejo de estados de carga.
- **Siguiente paso**: Integrar estas pantallas en la navegación principal y comenzar con el sistema de **Peticiones de Oración**.

## 2026-05-27

- **Migración a Riverpod**: Se implementan `app_providers.dart` para gestionar `StorageService`, `AuthService` y `FirestoreService`.
- **Refactorización UI**: Se limpia `CalendarioView` eliminando la inyección manual de dependencias en favor de `ConsumerStatefulWidget`.
- **Backend Social**: Se crea `FirestoreService` y el modelo `Reflexion` para soportar el feed devocional.
- **Siguiente paso**: Implementar la lógica de publicación en `PublicarReflexionScreen` y mostrar los datos en tiempo real en el `FeedScreen`.

## 2026-05-26 (continuación 3)

- Se define la arquitectura tecnológica escalable:
  - Flutter + Riverpod para frontend y estado global.
  - Firebase (Firestore, Auth, Storage, Messaging, Functions) para backend, base de datos y notificaciones.
  - Se agregan dependencias de Firebase y Riverpod al pubspec.yaml.
- Siguiente paso: Inicializar Firebase en el proyecto y crear providers base con Riverpod.
# Bitácora de Desarrollo — AltarDiario Red Social

Este archivo documenta los avances, decisiones y tareas realizadas en la evolución de la app AltarDiario hacia una red social devocional.


## 2026-05-26

## 2026-05-26 (continuación)

- Se crean los modelos base: Usuario, Reflexion y PeticionOracion en lib/data/models/.
- Se implementa AuthService para autenticación con Firebase Auth (inicio anónimo y base para Google/email).
- Se crea la pantalla base FeedScreen en lib/presentation/screens/ para mostrar el feed devocional.
- Siguiente paso: Integrar el feed con backend y estado global (Provider/Riverpod), y crear pantallas de publicación de reflexión y perfil de usuario.

- **Inicio de transformación**: Se decide evolucionar la app de lectura bíblica diaria a una red social devocional.
- **Nuevas funcionalidades propuestas:**
  - Publicar reflexiones tras cada lectura.
  - Feed devocional para ver reflexiones de otros usuarios.
  - Compañeros de oración: agregar amigos, enviar/recibir peticiones de oración.
  - Notificaciones sociales (comentarios, reacciones, peticiones).
  - Perfil de usuario con estadísticas y reflexiones.
  - Persistencia y sincronización en la nube (Firebase/Supabase sugerido).
- **Siguiente paso:**
  - Proponer arquitectura y estructura de archivos para la nueva versión social.

---

> Agrega aquí cada avance, decisión o cambio relevante para mantener el historial del proyecto actualizado.

## 2026-05-26 (continuación 2)

- Se crean pantallas base para publicar reflexión (PublicarReflexionScreen) y perfil de usuario (PerfilScreen) en lib/presentation/screens/.
- Siguiente paso: Integrar el feed y reflexiones con backend y estado global, y conectar la publicación de reflexiones al feed.
