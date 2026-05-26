# Propuesta de Arquitectura — AltarDiario Social

## 1. Estructura de Carpetas Sugerida

lib/
 ├── core/
 ├── data/
 │    ├── datasources/           # Firebase/Supabase API, local cache
 │    ├── models/                # Modelos: Usuario, Reflexion, PeticionOracion
 │    └── repositories/          # Abstracciones y lógica de acceso
 ├── domain/
 │    ├── entities/              # Entidades de negocio
 │    ├── usecases/              # Casos de uso: publicar reflexión, agregar compañero, etc.
 │    └── repositories/          # Interfaces
 ├── presentation/
 │    ├── screens/
 │    │    ├── feed_screen.dart
 │    │    ├── reflexion_screen.dart
 │    │    ├── oracion_screen.dart
 │    │    ├── perfil_screen.dart
 │    │    └── auth_screen.dart
 │    ├── widgets/
 │    └── providers/             # Provider/Riverpod para estado global
 ├── services/
 │    ├── notification_service.dart
 │    └── auth_service.dart      # Login/registro (Google, email, anónimo)
 ├── theme/
 └── main.dart

## 2. Modelos Clave

- Usuario: id, nombre, email, foto, lista de compañeros
- Reflexion: id, usuarioId, texto, fecha, likes, comentarios
- PeticionOracion: id, usuarioId, texto, fecha, oradoPor[]

## 3. Funcionalidades Iniciales

- Autenticación básica (Google/email/anónimo)
- Publicar reflexión diaria
- Feed devocional (todas las reflexiones)
- Comentar y dar “me gusta”
- Agregar compañeros de oración
- Enviar/recibir peticiones de oración
- Notificaciones sociales
- Perfil de usuario

## 4. Backend sugerido

- Firebase (Firestore, Auth, Cloud Functions, Storage)
- Alternativa: Supabase (Postgres, Auth, Storage)

## 5. Siguientes pasos

- Crear modelos y pantallas base
- Integrar autenticación
- Implementar feed y reflexiones
- Documentar avances en BITACORA.md

---

> Esta arquitectura permite escalar la app y separar claramente la lógica social/devocional.
