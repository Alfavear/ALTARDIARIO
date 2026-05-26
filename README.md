# 📖 AltarDiario: Tu Hábito Devocional Social

> "Tu hábito diario con Dios, ahora en comunidad."
>
> AltarDiario es una aplicación móvil multiplataforma (iOS y Android) diseñada para ayudarte a mantener un hábito constante de lectura bíblica diaria, transformándose en una plataforma social devocional donde puedes compartir tus reflexiones y conectar con otros creyentes.
>
> **Estado del Proyecto:** En desarrollo activo (Fase 2: Núcleo Social - Reflexiones)
>
> ![AltarDiario Logo](https://via.placeholder.com/150/007bff/ffffff?text=AltarDiario+Logo)
> _(Placeholder para el logo oficial de AltarDiario)_
>
> ## 🚀 Características Principales
>
> ### Core Devocional
> - **Plan de Lectura Bíblica Anual (365 días):** Un plan predefinido para leer la Biblia completa en un año.
> - **Seguimiento de Progreso:** Marca fácilmente los días completados y visualiza tu avance.
> - **Sistema de Rachas (Streaks):** Inspirado en Duolingo, fomenta la constancia con un contador de días consecutivos de lectura.
> - **Notificaciones Locales:** Recordatorios diarios para no perder tu hábito.
> - **Lectura Online Integrada:** Abre pasajes directamente en BibleGateway desde la app.
>
> ### Funcionalidades Sociales (En desarrollo)
> - **Autenticación de Usuario:** Inicio de sesión anónimo, Google y Email (próximamente).
> - **Feed Devocional Comunitario:** Explora reflexiones compartidas por otros usuarios.
> - **Publicación de Reflexiones:** Comparte tus pensamientos y aprendizajes después de cada lectura.
> - **Interacciones Sociales:** "Me gusta" (Likes) en las reflexiones (próximamente).
> - **Seguidores y Comunidad:** Sistema de seguimiento para conectar con amigos y hermanos.
> - **Chats Internos:** Mensajería privada para apoyo espiritual y comunión.
> - **Perfil de Usuario:** Estadísticas personales, rachas y reflexiones publicadas (próximamente).
> - **Sincronización en la Nube:** Guarda tu progreso y datos sociales en Firebase para acceder desde cualquier dispositivo (próximamente).
>
> ## 🛠️ Tecnologías Utilizadas
>
> - **Frontend:** Flutter (Dart)
> - **Gestión de Estado:** Riverpod
> - **Backend:** Firebase
>   - **Firestore:** Base de datos NoSQL para datos sociales (reflexiones, peticiones, perfiles).
>   - **Authentication:** Gestión de usuarios.
>   - **Storage:** Almacenamiento de archivos (ej. fotos de perfil, si se implementan).
>   - **Cloud Functions:** Lógica de backend sin servidor (para futuras funcionalidades avanzadas).
> - **Persistencia Local:** `shared_preferences`
> - **Notificaciones:** `flutter_local_notifications`
> - **Navegación Externa:** `url_launcher`
>
> ## 🏗️ Arquitectura del Proyecto
>
> El proyecto sigue una arquitectura modular y escalable, inspirada en principios de Clean Architecture y la separación de responsabilidades:
>
> ```text
> lib/
>  ├── core/                  # Utilidades, temas y constantes globales
>  ├── data/                  # Implementación de datos
>  │    ├── models/           # Modelos: Reflexion, Usuario, PeticionOracion, LecturaDia
>  ├── presentation/          # Capa de Interfaz de Usuario
>  │    ├── screens/          # Vistas principales de la aplicación
>  │    ├── widgets/          # Componentes de UI reutilizables
>  ├── providers/             # Gestión de estado global con Riverpod
>  ├── services/              # Servicios: Firebase, Auth, Storage, Notifications
>  ├── theme/                 # Design System (Colores, Tipografía, Estilos)
>  ├── views/                 # Componentes de vista especializados (Legacy/Refactor)
>  └── main.dart              # Inicialización de la App
> ```
>
> ## ⚙️ Instalación y Configuración
>
> Para ejecutar AltarDiario en tu entorno local, sigue estos pasos:
>
> ### Prerrequisitos
> - Flutter SDK (versión 3.x o superior recomendada)
> - Firebase CLI
> - Un editor de código (VS Code, Android Studio)
>
> ### Pasos
>
> 1.  **Clonar el Repositorio:**
>     ```bash
>     git clone https://github.com/tu-usuario/AltarDiario.git
>     cd AltarDiario
>     ```
>
> 2.  **Instalar Dependencias de Flutter:**
>     ```bash
>     flutter pub get
>     ```
>
> 3.  **Configurar Firebase:**
>     - Crea un nuevo proyecto en la Consola de Firebase.
>     - Agrega una aplicación Android y una iOS a tu proyecto Firebase.
>     - Sigue las instrucciones de Firebase para descargar `google-services.json` (para Android) y `GoogleService-Info.plist` (para iOS) y colócalos en las ubicaciones correctas (`android/app/` y `ios/Runner/` respectivamente).
>     - Habilita **Firestore Database**, **Authentication** (Anónimo y Google) y **Cloud Storage**.
>
> 4.  **Ejecutar la Aplicación:**
>     ```bash
>     flutter run --debug
>     ```
>
> ## 🗺️ Roadmap del Proyecto
>
> Estamos en una transición activa hacia una plataforma social. Nuestro progreso se mide en 5 hitos principales:
>
> 1.  **Fase 1: Infraestructura ✅** (Finalizado: Riverpod, Navegación Global, Base Firebase).
> 2.  **Fase 2: El Altar Social 🕒** (En proceso: Feed en tiempo real, publicación de reflexiones, interacciones).
> 3.  **Fase 3: Comunidad de Oración** (Próximamente: Sistema de peticiones y apoyo mutuo).
> 4.  **Fase 4: Identidad & Sincronización 🕒** (En proceso: Perfiles dinámicos, estadísticas y Cloud Sync).
> 5.  **Fase 5: Excelencia UI/UX** (Próximamente: Gamificación, animaciones premium y notificaciones push).
>
> Consulta la `BITACORA.md` para ver el historial técnico detallado de cada día.
>
> ## 🤝 Contribuciones
>
> ¡Las contribuciones son bienvenidas! Si deseas contribuir, por favor, sigue estos pasos:
>
> 1.  Haz un fork del repositorio.
> 2.  Crea una nueva rama (`git checkout -b feature/nueva-funcionalidad`).
> 3.  Realiza tus cambios y commitea (`git commit -am 'feat: Añade nueva funcionalidad X'`).
> 4.  Sube tus cambios (`git push origin feature/nueva-funcionalidad`).
> 5.  Abre un Pull Request.
>
> ## 📄 Licencia
>
> Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.
>
> ## 📧 Contacto
>
> Para cualquier pregunta o sugerencia, puedes contactar a [Tu Nombre/Email/GitHub].
