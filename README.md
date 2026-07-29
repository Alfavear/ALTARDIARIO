<div align="center">

<img src="assets/logo_app.png" alt="AltarDiario Logo" width="120" />

# AltarDiario

**Tu hábito devocional diario — ahora en comunidad.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-3.x-00BFA5)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Android](https://img.shields.io/badge/Android-%E2%9C%93-3DDC84?logo=android)](https://play.google.com)
[![iOS](https://img.shields.io/badge/iOS-%E2%9C%93-000000?logo=apple)](https://www.apple.com/app-store/)
[![Web](https://img.shields.io/badge/Web-%E2%9C%93-4285F4?logo=google-chrome)](https://altardiario-ec25f.web.app)

</div>

---

## ¿Qué es AltarDiario?

AltarDiario es una **red social devocional** para creyentes que quieren mantener un hábito constante de lectura bíblica y compartir su camino de fe con una comunidad real. Combina un lector bíblico completo, un plan de lectura anual, gamificación espiritual y funcionalidades sociales en una sola app nativa multiplataforma.

> *"Persevera en la lectura, en la exhortación y en la enseñanza."* — 1 Timoteo 4:13

---

## ✨ Características Principales

### 📖 Lectura Bíblica

| Funcionalidad | Detalle |
|---|---|
| **11 versiones bíblicas** | RV1960, RV1909, LBLA, RVC, DHH, NTV, NVI, PDT, BTX, RVR, TLA |
| **Comparador de versiones** | Vista paralela o versículo a versículo entre dos traducciones |
| **Gestos y temas** | Swipe para cambiar capítulo · Temas Claro / Sepia / Noche |
| **Marcadores y notas** | Resalta versículos, agrega notas personales por pasaje |
| **Plan anual** | 365 lecturas diarias para leer la Biblia completa en un año |
| **Descarga offline** | Versiones disponibles sin conexión a internet |

### 🏛️ Altar Comunitario (Feed Social)

| Funcionalidad | Detalle |
|---|---|
| **Reflexiones** | Publica tus meditaciones diarias vinculadas al pasaje del día |
| **Reacciones** | ❤️ 🙏 🔥 💡 — cuatro tipos de reacción espiritual |
| **Comentarios en vivo** | Comentarios en tiempo real con likes por comentario |
| **Tags automáticos** | Etiquetas extraídas del texto de la reflexión |
| **Búsqueda** | Filtra el feed por texto libre o tags |
| **Perfiles públicos** | Visita el perfil de cualquier miembro de la comunidad |

### 🙏 Peticiones de Oración

- Publica peticiones personales o de intercesión
- Botón **"Amén"** para apoyar en oración a tus hermanos
- Categorías de petición (salud, familia, trabajo, otros)

### 👤 Perfil e Identidad

- Avatar personalizable con foto o emojis espirituales
- Estadísticas reales: rachas, lecturas completadas, reflexiones publicadas
- Seguir / Dejar de seguir otros usuarios
- Listas de **Siguiendo** y **Seguidores**

### 🏆 Gamificación Espiritual

- **16 insignias** desbloqueables en 5 categorías: Rachas, Lectura, Comunidad, Oración, Especiales
- **10 niveles de XP**: de Semilla 🌱 a Maestro Espiritual 👑
- Notificación de celebración al desbloquear una insignia
- Barra de progreso de XP en tiempo real

### 💬 Foro Bíblico

- Debates por libro de la Biblia
- Votos (👍 / 👎) en debates y respuestas
- Hilo de respuestas en tiempo real

### 🎯 Modo Enfoque

- Bloquea la navegación entre tabs hasta completar la lectura del día
- Cancela notificaciones push mientras está activo
- Botón de activación/desactivación desde la pantalla de inicio

### 👥 Comunidad y Rachas Compartidas

- Ranking de rachas entre tus amigos
- Sugerencias de nuevos miembros a seguir
- Sistema de seguimiento completo (siguiendo / seguidores)

---

## 🛠️ Stack Tecnológico

```
Flutter 3.x (Dart)           — Framework UI multiplataforma
Riverpod 3.x                 — Gestión de estado reactivo
Firebase Auth                — Autenticación (Anónimo, Google, Apple)
Cloud Firestore              — Base de datos en tiempo real
Firebase Storage             — Fotos de perfil
Firebase Cloud Messaging     — Notificaciones push
SQLite (via sqflite)         — Biblias descargadas (nativo)
shared_preferences           — Persistencia local (rachas, configuración)
flutter_local_notifications  — Recordatorios diarios
google_fonts                 — Tipografía premium
flutter_launcher_icons       — Íconos de app en todos los densities
```

---

## 🏗️ Arquitectura del Proyecto

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart                # Colores, gradientes, sombras, tema Material
│   └── services/
│       ├── notification_service.dart     # Notificaciones locales + FCM push
│       ├── community_policy_service.dart # Normas de la comunidad (5 reglas)
│       └── gamification_service.dart    # Badges, XP, niveles (16 insignias)
├── data/
│   ├── models/
│   │   ├── badge.dart                    # Badge: rareza, categoría, criterios, XP
│   │   ├── bible_models.dart             # BibleVersion, BibleVerse, BibleNote
│   │   ├── comment.dart                  # Comentarios en reflexiones
│   │   ├── debate.dart / debate_reply.dart
│   │   ├── lectura_dia.dart              # Plan de lectura diario
│   │   ├── note.dart                     # Notas personales locales
│   │   ├── peticion_oracion.dart         # Peticiones de oración
│   │   ├── reflexion.dart                # Publicaciones del feed
│   │   └── usuario.dart                  # Perfil: badges[], totalPuntos, nivel
│   └── services/
│       ├── auth_service.dart             # Firebase Auth wrapper
│       ├── bible_service.dart            # Carga de Biblias (SQLite / web memory)
│       ├── bible_download_service.dart   # Descarga desde bolls.life API
│       ├── firestore_service.dart        # CRUD Firestore completo
│       └── storage_service.dart         # SharedPreferences (rachas, notas, enfoque)
└── presentation/
    ├── providers/
    │   └── app_providers.dart            # Todos los providers Riverpod (fuente única)
    ├── widgets/
    │   └── guest_access_restricted_widget.dart
    └── screens/
        ├── splash_screen.dart
        ├── login_screen.dart             # Google · Apple · Invitado
        ├── main_navigation_view.dart     # IndexedStack 5 tabs
        ├── home_screen.dart              # Inicio, versículo del día, rachas
        ├── calendario_view.dart          # Plan anual de lectura
        ├── feed_screen.dart              # Altar Comunitario
        ├── oracion_screen.dart           # Peticiones de oración
        ├── perfil_screen.dart            # Perfil, insignias, configuración
        ├── bible_reader_screen.dart      # Lector bíblico
        ├── bible_compare_screen.dart     # Comparador de versiones
        ├── bible_versions_screen.dart    # Gestión de versiones
        ├── publicar_reflexion_screen.dart
        ├── public_profile_screen.dart
        ├── followers_screen.dart
        ├── notes_screen.dart / note_editor_screen.dart
        ├── foro_screen.dart / crear_debate_screen.dart / debate_detail_screen.dart
        └── amigos_rachas_screen.dart
```

---

## 🚀 Instalación Local

### Prerrequisitos

- Flutter SDK ≥ 3.5.0
- Dart ≥ 3.0
- Android Studio / Xcode (para nativo) o Chrome (para web)

### Pasos

```bash
# 1. Clonar el repositorio
git clone https://github.com/Alfavear/ALTARDIARIO.git
cd ALTARDIARIO

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en modo debug
flutter run -d chrome        # Web
flutter run -d android       # Android
flutter run -d ios           # iOS (requiere macOS)
```

> **Nota**: El archivo `.env` contiene claves de API y no está en el repositorio.

---

## 🧪 Tests

```bash
flutter test                       # Todos los tests
flutter test test/models/          # Tests de modelos
flutter test test/screens/         # Tests de pantallas (widget tests)
flutter test test/services/        # Tests de servicios
flutter analyze                    # Análisis estático (0 errores en producción)
```

---

## 🔥 Comandos de Build

```bash
flutter build apk --release              # APK Android
flutter build appbundle --release        # App Bundle (Google Play)
flutter build web --release              # Web production
flutter build ios --release              # iOS (requiere macOS + Xcode)
flutter pub run flutter_launcher_icons   # Regenerar íconos de app
```

---

## ☁️ Firebase

| Servicio | Uso |
|---|---|
| **Authentication** | Anónimo, Google Sign-In, Apple Sign-In |
| **Cloud Firestore** | Reflexiones, peticiones, perfiles, debates, comentarios |
| **Storage** | Fotos de perfil |
| **Cloud Messaging** | Notificaciones push |

**Project ID**: `altardiario-ec25f`
**Reglas**: [`firestore.rules`](firestore.rules)
**Índices**: [`firestore.indexes.json`](firestore.indexes.json)

---

## 🗺️ Estado del Proyecto

| Módulo | Estado |
|--------|--------|
| Lectura Bíblica (11 versiones + offline) | ✅ Completo |
| Comparador de versiones en paralelo | ✅ Completo |
| Plan anual 365 días | ✅ Completo |
| Marcadores, highlights y notas | ✅ Completo |
| Swipe navigation + 3 temas de lectura | ✅ Completo |
| Feed de reflexiones en tiempo real | ✅ Completo |
| Reacciones, likes y comentarios | ✅ Completo |
| Peticiones de oración + Amén | ✅ Completo |
| Perfiles públicos + Follow system | ✅ Completo |
| Foro Bíblico (debates y respuestas) | ✅ Completo |
| Ranking de rachas entre amigos | ✅ Completo |
| Gamificación (16 badges, 10 niveles, XP) | ✅ Completo |
| Panel de Perfil + Configuración completa | ✅ Completo |
| Política de Comunidad (5 normas) | ✅ Completo |
| Seguridad por rol (invitado / registrado) | ✅ Completo |
| Modo Enfoque (bloqueo de navegación) | ✅ Completo |
| Sugerencias de amistad | ✅ Completo |
| Notificaciones locales + FCM | ✅ Completo |
| Ícono APK personalizado | ✅ Completo |
| Web App | ✅ Completo |
| Chat privado entre usuarios | 🔄 Implementado, pendiente de UI |

---

## 📋 Documentación Interna

| Archivo | Contenido |
|---|---|
| [`BITACORA.md`](BITACORA.md) | Historial detallado de cada sesión de desarrollo |
| [`SYSTEM.md`](SYSTEM.md) | Referencia técnica: providers, pantallas, Firestore |
| [`ARQUITECTURA_SOCIAL.md`](ARQUITECTURA_SOCIAL.md) | Arquitectura, flujo de navegación y estado de features |
| [`AGENTS.md`](AGENTS.md) | Guía para el agente de IA (convenciones, patrones, reglas) |

---

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Para contribuir:

1. Fork el repositorio
2. Crea una rama: `git checkout -b feat/mi-mejora`
3. Commitea con mensaje descriptivo: `git commit -m "feat: descripción"`
4. Sube los cambios: `git push origin feat/mi-mejora`
5. Abre un Pull Request

Por favor sigue las [convenciones de código](AGENTS.md) del proyecto.

---

## 📄 Licencia

Este proyecto está bajo la **Licencia MIT**.

---

<div align="center">

**Hecho con ❤️ y 🙏 para la comunidad de fe**

[GitHub](https://github.com/Alfavear/ALTARDIARIO) · [Reportar un bug](https://github.com/Alfavear/ALTARDIARIO/issues) · [Solicitar feature](https://github.com/Alfavear/ALTARDIARIO/issues)

</div>
