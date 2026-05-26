# Plan de Implementación — altarDiario (iOS & Android Flutter App)

Desarrollo de una aplicación móvil moderna llamada **altarDiario** (anteriormente Biblia Anual) con diseño minimalista, elegante y devocional. Ayudará a los usuarios a realizar el seguimiento de su lectura bíblica diaria durante un año en sistemas operativos Android e iOS.

## Análisis de Viabilidad y Tecnologías

Tras evaluar los requerimientos del proyecto (fluidez, bajo peso, funcionamiento sin conexión y soporte idéntico para Android e iOS), confirmamos que **Flutter** es la opción ideal por las siguientes razones:

1. **Rendimiento y Fluidez**: Flutter renderiza directamente en el lienzo del dispositivo utilizando **Impeller** (en iOS y Android modernos), lo que garantiza transiciones y animaciones fluidas a 60/120 fps, superando a frameworks basados en WebViews (como Ionic/Capacitor) y evitando el puente de JavaScript de React Native.
2. **Multiplataforma Real**: Una sola base de código permite generar de forma nativa la aplicación tanto para Android (APK/AAB) como para iOS (IPA).
3. **Persistencia Ligera**: Dado que solo guardaremos la fecha de inicio del plan, las fechas completadas y las estadísticas de racha, **`shared_preferences`** es la opción más limpia y liviana. Evitamos bases de datos complejas para mantener la huella en disco al mínimo.
4. **Diseño de Calendario Scroll Vertical**: Para garantizar la estética Duolingo de scroll continuo y el control de animaciones al marcar días, implementaremos un listado vertical infinito/continuo de meses utilizando `ListView.builder` combinado con un grid de días nativo (`GridView.builder`). Esto nos da total flexibilidad de diseño y rendimiento excelente sin dependencias pesadas.

## User Review Required

> [!IMPORTANT]
> **Estética "Estilo Duolingo"**: La cabecera principal tendrá un gradiente azul devocional vibrante con bordes inferiores curvos pronunciados. Mostrará el título **altarDiario**, el subtexto *"Tu hábito diario con Dios"* y un banner redondeado y elegante para la **Racha Diaria** (representada con un icono de fuego 🔥 y el conteo de días activos).
> 
> **Lógica de Racha (Streak)**: Al marcar la lectura del día de hoy como completada, la aplicación calculará dinámicamente la racha de días consecutivos leídos de forma retrospectiva. Si el usuario rompe la racha (pasa un día sin leer), el contador se reiniciará. También guardaremos la racha máxima alcanzada para fomentar el hábito.
> 
> **Plan de Lectura Precargado**: Se generará un plan de lectura bíblica completo para 365 días (del 01-01 al 12-31) y se almacenará en un archivo de assets JSON (`assets/plan_lectura.json`). Cada día calendario tiene asociado un pasaje de lectura fijo.

> [!WARNING]
> **Configuración de Notificaciones**: Las notificaciones locales requieren permisos en iOS (solicitud del sistema al iniciar) y en Android 13+ (POST_NOTIFICATIONS). Los recordatorios offline se programarán diariamente a las 8:00 PM si el día actual no se ha marcado como completado.

> [!CAUTION]
> **Entorno de Compilación**: Las herramientas `flutter` y `android` no están en el PATH actual de este agente. Configuraremos el entorno local en la fase de ejecución para compilar el APK de Android de forma automatizada. Adicionalmente, entregaremos el código fuente 100% completo, organizado y compatible con Xcode (iOS) y Gradle (Android) para que puedas compilarlo en cualquier máquina.

## Open Questions

Ninguna por el momento. El cambio a diseño de calendario nativo/personalizado y la persistencia ligera optimizan la fluidez al máximo.

---

## Proposed Changes

### Estructura del Proyecto Flutter

Inicializaremos un proyecto de Flutter en el directorio actual utilizando `flutter create`. El nombre del paquete será `com.altardiario.app`.

La estructura de archivos de la aplicación será la siguiente:
- `assets/plan_lectura.json`: Datos del plan de lectura de 365 días estructurados del 1 al 365.
- `lib/main.dart`: Punto de entrada de la aplicación, inicialización de servicios y enrutamiento básico.
- `lib/models/lectura_dia.dart`: Modelo de datos para las lecturas diarias y fechas correspondientes.
- `lib/services/storage_service.dart`: Interfaz con `shared_preferences` para guardar la fecha de inicio, progreso (fechas completadas en formato `yyyy-MM-dd`) y estado general.
- `lib/services/notification_service.dart`: Inicialización y programación de las notificaciones locales con `flutter_local_notifications`.
- `lib/theme/app_theme.dart`: Definición del diseño visual (Azul devocional, blanco, gris suave, verde de completado) y tipografías.
- `lib/views/inicio_view.dart`: Pantalla de bienvenida y configuración de la fecha de inicio.
- `lib/views/calendario_view.dart`: Pantalla con la grilla mensual clásica (Domingo-Sábado) mostrando los días y pasajes de lectura en la celda.
- `lib/views/anual_view.dart`: Pantalla del progreso anual con minicalendarios mensuales.
- `lib/views/main_navigation_view.dart`: Contenedor principal con barra de navegación inferior.

---

### Componentes y Archivos

#### [NEW] [plan_lectura.json](file:///C:/Users/ialvear/.gemini/antigravity/scratch/AltarDiario/assets/plan_lectura.json)
Archivo JSON estructurado del día 1 al 365 con los datos reales extraídos del archivo oficial de Excel provisto por el usuario ([Plan Anual de Lectura biblica Trastornadores.xlsx](file:///C:/Users/ialvear/.gemini/antigravity/scratch/AltarDiario/Plan%20Anual%20de%20Lectura%20biblica%20Trastornadores.xlsx)):
```json
{
  "1": "Génesis 1–3; Juan 1–2",
  "2": "Génesis 4–5; Juan 3",
  ...
  "365": "Apocalipsis 22"
}
```
*(Nota: En la fase de ejecución utilizaremos un script para compilar este JSON a partir de los datos exactos del Excel oficial o sus equivalentes en texto ya validados).*

#### [NEW] [storage_service.dart](file:///C:/Users/ialvear/.gemini/antigravity/scratch/AltarDiario/lib/services/storage_service.dart)
Clase para persistir localmente:
- `plan_start_date`: Fecha de inicio del plan (DateTime).
- `completed_dates`: Lista de strings con las fechas calendario completadas en formato `yyyy-MM-dd`.
- `is_plan_generated`: Booleano para control de flujo de bienvenida.

#### [NEW] [calendario_view.dart](file:///C:/Users/ialvear/.gemini/antigravity/scratch/AltarDiario/lib/views/calendario_view.dart)
- Grilla mensual interactiva de 7 columnas (Domingo a Sábado), simulando un calendario físico pero adaptado a una app móvil premium.
- Cada celda mostrará:
  - Número del día calendario en la esquina superior derecha.
  - Cita bíblica del día de forma abreviada y legible en la parte inferior.
  - Color de fondo: Blanco/Gris suave para días pendientes, Verde suave para días leídos.
- Al tocar una celda se abrirá un panel de detalle inferior (BottomSheet) con:
  - Fecha larga formateada (ej: "Martes, 1 de Enero del 2026").
  - Lecturas completas del día.
  - Botón principal: **"Marcar como leído"** / **"Marcar como pendiente"**.
  - Enlace externo: **"Leer pasajes en línea"** que abrirá el navegador del dispositivo (`url_launcher`) apuntando a BibleGateway o BibleStudyTools con el pasaje correspondiente, facilitando la lectura directa al usuario.

#### [NEW] [anual_view.dart](file:///C:/Users/ialvear/.gemini/antigravity/scratch/AltarDiario/lib/views/anual_view.dart)
Dashboard con el progreso total del año (porcentaje y contador de lecturas completadas). Muestra 12 mini layouts de mes (grillas sencillas de calor) donde cada cuadradito representa un día (verde si está completado, gris si está pendiente).

---

## Verification Plan

### Automated Tests
- Ejecutaremos pruebas de compilación en Android usando:
  `flutter build apk --split-per-abi` o `flutter build apk --release` para comprobar que compile sin errores.

### Manual Verification
- Verificación del diseño en el simulador o a través de la compilación de la APK.
- Comprobación de que al presionar "Marcar como leído", el día en el calendario se actualiza a color verde de inmediato.
- Comprobación de la navegación horizontal/vertical entre los meses del calendario.
- Comprobación de que la redirección de enlace externo a la lectura en línea funcione correctamente abriendo el navegador.
- Comprobación de que los datos persisten al reiniciar la aplicación.
- Monitoreo de logs de programación de notificaciones para verificar que se programen a las 8:00 PM.
