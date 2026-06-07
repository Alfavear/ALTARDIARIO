# 🎨 Design System - AltarDiario

> **Tu hábito diario con Dios, ahora en comunidad**
>
> Documento completo del contexto gráfico, paleta de colores, tipografía y componentes de la aplicación móvil AltarDiario.

---

## 📋 Índice

1. [Visión de Diseño](#visión-de-diseño)
2. [Paleta de Colores](#paleta-de-colores)
3. [Tipografía](#tipografía)
4. [Componentes Base](#componentes-base)
5. [Layout y Espaciado](#layout-y-espaciado)
6. [Estilos de Sombras](#estilos-de-sombras)
7. [Gradientes](#gradientes)
8. [Pantallas Principales](#pantallas-principales)
9. [Componentes de UI](#componentes-de-ui)
10. [Estados de Interacción](#estados-de-interacción)
11. [Guías de Implementación](#guías-de-implementación)

---

## 🎯 Visión de Diseño

AltarDiario es una aplicación devocional social que combina:

- **Funcionalidad**: Plan de lectura bíblica, seguimiento de progreso y rachas
- **Comunidad**: Feed social, reflexiones compartidas, conexión con otros usuarios
- **Espiritualidad**: Diseño inspirador que fomenta la constancia y el hábito devocional
- **Modernidad**: Interfaz limpia, intuitiva y accesible con Material Design 3

### Principios de Diseño

- **Claridad**: Información jerarquizada y fácil de entender
- **Inspiración**: Colores y elementos que motiven la práctica diaria
- **Accesibilidad**: Contraste suficiente y tamaños legibles
- **Consistencia**: Uso uniforme de componentes y patrones
- **Comunidad**: Elementos sociales destacados y accesibles

---

## 🎨 Paleta de Colores

### Colores Primarios

| Nombre | Hex | RGB | Uso |
|--------|-----|-----|-----|
| **Primary Blue** | `#1565C0` | rgb(21, 101, 192) | Color principal, botones, navegación |
| **Primary Blue Dark** | `#0D47A1` | rgb(13, 71, 161) | Headers, elementos de énfasis |
| **Primary Blue Light** | `#42A5F5` | rgb(66, 165, 245) | Estados hover, elementos secundarios |
| **Accent Gold** | `#FFB300` | rgb(255, 179, 0) | Acentos, elementos destacados |
| **Accent Gold Light** | `#FFD54F` | rgb(255, 213, 79) | Variación clara del acento |

### Colores de Estado

| Nombre | Hex | RGB | Uso |
|--------|-----|-----|-----|
| **Completed Green** | `#43A047` | rgb(67, 160, 71) | Lectura completada, éxito |
| **Completed Green Light** | `#E8F5E9` | rgb(232, 245, 233) | Fondo de estado completado |
| **Pending Gray** | `#F5F5F5` | rgb(245, 245, 245) | Elementos pendientes, deshabilitados |
| **Pending Gray Dark** | `#BDBDBD` | rgb(189, 189, 189) | Bordes, textos deshabilitados |
| **Today Highlight** | `#FFF3E0` | rgb(255, 243, 224) | Resaltado del día actual |
| **Streak Orange** | `#FF6D00` | rgb(255, 109, 0) | Contador de rachas |
| **Streak Orange Light** | `#FFAB40` | rgb(255, 171, 64) | Variación clara del streak |
| **Missed Day Bg** | `#FFF8F8` | rgb(255, 248, 248) | Fondo de días perdidos |

### Colores de Superficie

| Nombre | Hex | RGB | Uso |
|--------|-----|-----|-----|
| **Scaffold Background** | `#F8F9FE` | rgb(248, 249, 254) | Fondo principal de las pantallas |
| **Card Background** | `#FFFFFF` | rgb(255, 255, 255) | Tarjetas, componentes |
| **Surface Dark** | `#1A237E` | rgb(26, 35, 126) | Fondos oscuros, overlays |

### Colores de Texto

| Nombre | Hex | RGB | Uso |
|--------|-----|-----|-----|
| **Text Primary** | `#212121` | rgb(33, 33, 33) | Texto principal, títulos |
| **Text Secondary** | `#757575` | rgb(117, 117, 117) | Texto secundario, descripciones |
| **Text on Primary** | `#FFFFFF` | rgb(255, 255, 255) | Texto sobre colores primarios |
| **Text on Accent** | `#212121` | rgb(33, 33, 33) | Texto sobre colores de acento |

### Ejemplos de Uso

```dart
// Uso en Flutter
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

// Botón primario
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryBlue,
    foregroundColor: AppTheme.textOnPrimary,
  ),
  onPressed: () {},
  child: const Text('Continuar'),
);

// Indicador de progreso completado
Container(
  color: AppTheme.completedGreen,
  child: const Text('✓ Completado'),
);

// Streak badge
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.streakGradient,
    borderRadius: BorderRadius.circular(8),
  ),
  child: const Text('7 días'),
);
```

---

## 🔤 Tipografía

### Familia de Fuente

- **Fuente Principal**: Google Fonts - **Inter**
- **Características**: Clean, moderna, legible, excelente para interfaces digitales
- **Pesos disponibles**: 400, 600, 700, 800

### Escala Tipográfica

| Nivel | Nombre | Tamaño | Peso | Espaciado | Uso |
|-------|--------|--------|------|-----------|-----|
| **Nivel 1** | Headline Large | 28px | 800 | -0.5px | Títulos principales, headers de pantalla |
| **Nivel 2** | Headline Medium | 22px | 700 | -0.3px | Subtítulos, títulos de secciones |
| **Nivel 3** | Title Large | 18px | 600 | 0px | Títulos de tarjetas, encabezados |
| **Nivel 4** | Title Medium | 15px | 600 | 0px | Subtítulos de tarjetas |
| **Nivel 5** | Body Large | 15px | 400 | 0px | Texto de párrafos principales |
| **Nivel 6** | Body Medium | 13px | 400 | 0px | Texto de cuerpo secundario |
| **Nivel 7** | Body Small | 11px | 400 | 0px | Texto pequeño, notas |
| **Nivel 8** | Label Large | 14px | 600 | 0px | Botones, labels |

### Ejemplos de Uso en Flutter

```dart
// Headline Large
Text(
  'Mi Lectura Hoy',
  style: GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppTheme.textOnPrimary,
    letterSpacing: -0.5,
  ),
);

// Body Large
Text(
  'Génesis 1:1 - En el principio creó Dios...',
  style: GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppTheme.textPrimary,
  ),
);

// Label Large (botones)
Text(
  'COMPARTIR REFLEXIÓN',
  style: GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppTheme.textOnPrimary,
  ),
);
```

---

## 🧩 Componentes Base

### Botones

#### Elevated Button (Primario)

```
┌─────────────────────────┐
│   CONTINUAR LECTURA     │  <- Label Large (14px, w600)
└─────────────────────────┘
```

**Especificaciones:**
- Fondo: Primary Blue (`#1565C0`)
- Texto: Text on Primary (`#FFFFFF`)
- Padding: Horizontal 24px, Vertical 14px
- Border Radius: 16px (radiusMedium)
- Elevación: 0px (flat)
- Transición: 200ms
- Estado hover: Primary Blue Light

#### Text Button (Secundario)

```
Compartir reflexión  <- Texto sin fondo
```

**Especificaciones:**
- Sin fondo
- Texto: Primary Blue
- Transición: 200ms

### Tarjetas (Cards)

```
┌──────────────────────────────┐
│  📖 Lectura de Hoy           │
│  ─────────────────────────── │
│  Génesis 1:1-10              │
│  En el principio creó Dios... │
│                              │
│  [Leer en BibleGateway] [✓] │
└──────────────────────────────┘
```

**Especificaciones:**
- Fondo: Card Background (`#FFFFFF`)
- Border Radius: 16px (radiusMedium)
- Sombra: Soft Shadow
- Padding: 16px
- Elevación: 0px
- Usar en: Reflexiones, lecturas, elementos de lista

### Input Fields

```
┌──────────────────────────────┐
│ Tu reflexión aquí...          │
│                              │
│                              │
└──────────────────────────────┘
```

**Especificaciones:**
- Borde: 1px, Pending Gray Dark
- Border Radius: 8px (radiusSmall)
- Padding: 12px
- Focus: Border color Primary Blue
- Error: Border color Red
- Placeholder: Text Secondary

### Bottom Navigation

```
┌────────────────────────────┐
│ 🏠 📖 💬 🙏 👤            │  <- Iconos de 24px
│ Home Plan Feed Oración ... │
└────────────────────────────┘
```

**Especificaciones:**
- Fondo: Card Background
- Elevación: 8px
- Ícono activo: Primary Blue
- Ícono inactivo: Text Secondary
- Label: 12px, w600 (activo), w400 (inactivo)

---

## 📐 Layout y Espaciado

### Espaciado (Padding & Margin)

| Nombre | Valor | Uso |
|--------|-------|-----|
| **xxs** | 4px | Espaciado muy pequeño entre elementos |
| **xs** | 8px | Espaciado pequeño, separación mínima |
| **sm** | 12px | Espaciado pequeño-medio |
| **md** | 16px | Espaciado estándar (padding de cards) |
| **lg** | 24px | Espaciado grande entre secciones |
| **xl** | 32px | Espaciado muy grande, separación principal |
| **xxl** | 48px | Espaciado máximo |

### Border Radius

| Nombre | Valor | Uso |
|--------|-------|-----|
| **radiusSmall** | 8px | Input fields, pequeños componentes |
| **radiusMedium** | 16px | Cards, botones, componentes estándar |
| **radiusLarge** | 24px | Modales, componentes grandes |
| **radiusXLarge** | 32px | Headers, fondos completos |

### Grilla de Responsive

- **Mobile**: 360px - 430px (primario)
- **Tablet**: 600px - 1024px
- **Breakpoints**: 360px, 600px, 1024px

**Márgenes por viewport:**
- Mobile: 16px horizontales
- Tablet: 24px horizontales
- Desktop: 32px horizontales

---

## 🌫️ Estilos de Sombras

### Soft Shadow (Por defecto)

```dart
BoxShadow(
  color: Colors.black.withOpacity(0.06),
  blurRadius: 12,
  offset: Offset(0, 4),
);
```

**Uso**: Cards, componentes flotantes leves

### Medium Shadow (Énfasis)

```dart
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 20,
  offset: Offset(0, 8),
);
```

**Uso**: Modales, componentes destacados, overlays

### Jerarquía Visual

1. **Sin sombra**: Elementos de fondo, textos
2. **Soft shadow**: Cards, botones, componentes estándar
3. **Medium shadow**: Modales, elementos elevados
4. **Large shadow**: Overlays, elementos máxima elevación

---

## ✨ Gradientes

### Header Gradient

```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF0D47A1),  // Primary Blue Dark
    Color(0xFF1565C0),  // Primary Blue
    Color(0xFF1976D2),  // Primary Blue Light
  ],
);
```

**Uso**: Headers principales, app bar, secciones destacadas

### Streak Gradient

```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFF6D00),  // Streak Orange
    Color(0xFFFFAB40),  // Streak Orange Light
  ],
);
```

**Uso**: Badges de racha, elementos motivacionales

### Completed Gradient

```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF43A047),  // Completed Green
    Color(0xFF66BB6A),  // Completed Green Light
  ],
);
```

**Uso**: Indicadores de finalización, progreso completado

---

## 📱 Pantallas Principales

### 1. Splash Screen

**Propósito**: Pantalla de carga inicial

**Elementos:**
- Logo AltarDiario (centrado)
- Tagline: "Tu hábito diario con Dios"
- Indicador de carga
- Fondo con gradiente header

**Duración:** 2-3 segundos

### 2. Login Screen

**Propósito**: Autenticación de usuario

**Elementos:**
- Logo AltarDiario
- Título "Bienvenido a AltarDiario"
- Botón "Continuar anónimamente"
- Botón "Iniciar con Google"
- Botón "Iniciar con Apple" (iOS)
- Texto: "Inicia sesión para acceder a la comunidad"

**Flujo:**
1. Usuario toca botón de autenticación
2. Valida credenciales
3. Navega a Home Screen

### 3. Home Screen (Dashboard)

**Propósito**: Vista principal con progreso y acciones rápidas

**Elementos:**
- App Bar con Header Gradient
  - Título: "Mi Lectura Hoy"
  - Icono de menú (hamburguesa)
- Lectura del día (Card grande)
  - Referencia bíblica (ej: Génesis 1:1)
  - Fragmento de texto
  - Botón "Leer en BibleGateway"
  - Botón "Marcar como leído" (✓)
- Contador de racha (Streak Card)
  - Número de días
  - Icono de fuego
  - Gradiente streak
- Próximas lecturas (Scroll horizontal)
  - Lista de 3-4 lecturas próximas
- Sección de acciones
  - Botón "Mi Reflexión"
  - Botón "Ver Plan Anual"
- Bottom Navigation
  - Home (activo)
  - Calendario
  - Feed
  - Oración
  - Perfil

### 4. Calendar View

**Propósito**: Visualizar progreso mensual/anual

**Elementos:**
- Selector de mes/año
- Grilla de días (7x4 + vacantes)
- Leyenda de colores:
  - Verde: Completado
  - Gris: Pendiente
  - Naranja: Racha activa
- Estadísticas del mes
  - Días completados
  - Racha actual
  - Porcentaje

### 5. Feed Screen (Social)

**Propósito**: Ver reflexiones de la comunidad

**Elementos:**
- Input de búsqueda/filtro
- Tarjetas de reflexiones
  - Avatar del usuario
  - Nombre + fecha
  - Texto de reflexión
  - Referencia bíblica
  - Contador de likes
  - Botón de compartir
- Infinite scroll

### 6. Bible Reader Screen

**Propósito**: Leer pasajes bíblicos completos

**Elementos:**
- Referencia actual (sticky)
- Texto del pasaje
- Controles de fuente
  - Tamaño: A- A+
  - Versión bíblica selector
- Acciones
  - Compartir pasaje
  - Crear nota
  - Marcar como favorito

### 7. Reflection Editor Screen

**Propósito**: Crear y publicar reflexiones

**Elementos:**
- Campo de entrada de reflexión
- Selector de referencia bíblica
- Vista previa
- Botón "Publicar"
- Botón "Guardar como borrador"

### 8. Prayer Request Screen

**Propósito**: Sistema de peticiones de oración

**Elementos:**
- Lista de peticiones activas
- Filtro por categoría
- Botón "Nueva petición"
- Tarjetas con:
  - Descripción
  - Cantidad de oraciones
  - Botón "Orar"

### 9. Profile Screen

**Propósito**: Datos y estadísticas del usuario

**Elementos:**
- Avatar del usuario
- Nombre y correo
- Estadísticas
  - Total de lecturas
  - Racha actual
  - Reflexiones publicadas
- Lista de reflexiones publicadas
- Configuración de notificaciones
- Botón de cerrar sesión

---

## 🎯 Componentes de UI

### Lectura Card

```
┌─────────────────────────────────┐
│ 📖 Génesis 1:1                  │
│ ─────────────────────────────── │
│ En el principio creó Dios       │
│ los cielos y la tierra...       │
│                                 │
│ [Leer Online]  [Marcar ✓]      │
└─────────────────────────────────┘
```

### Day Indicator

```
Completado: ✓ verde fondo
Pendiente:  ○ gris claro
Hoy:        ◎ fondo amarillento
Racha:      🔥 gradiente naranja
```

### Streak Badge

```
┌──────────────────┐
│ 🔥 7 Días        │  <- Gradiente naranja
│ ¡Vas muy bien!  │
└──────────────────┘
```

### Social Like Button

```
┌──────────────┐
│ ❤️ 45        │
└──────────────┘
```

Estados:
- No presionado: Gris
- Presionado: Rojo
- Animación: Scale 1.0 → 1.2 → 1.0

### User Avatar

```
┌─────────┐
│   JD    │  <- Iniciales
└─────────┘
```

Tamaños:
- Small: 32px
- Medium: 48px
- Large: 64px

---

## 🎪 Estados de Interacción

### Botones

**Estados:**
1. **Default**: Color base
2. **Hover**: Color primario light (+10% brillo)
3. **Pressed**: Color primario dark (-10% brillo)
4. **Disabled**: Gray, opacidad 50%
5. **Loading**: Spinner centrado

**Transiciones:** 200ms ease-in-out

### Cards

**Estados:**
1. **Default**: Soft shadow
2. **Hover**: Medium shadow, scale 1.02
3. **Pressed**: Color primario light background
4. **Loading**: Skeleton shimmer

**Transiciones:** 300ms ease-in-out

### Text Fields

**Estados:**
1. **Idle**: Borde gris
2. **Focused**: Borde azul, sombra suave
3. **Filled**: Borde gris oscuro
4. **Error**: Borde rojo
5. **Disabled**: Fondo gris, texto gris

**Transiciones:** 200ms ease-in-out

### Animaciones Principales

| Elemento | Animación | Duración | Easing |
|----------|-----------|----------|--------|
| Botón presión | Scale | 150ms | easeInOut |
| Transición pantalla | Fade/Slide | 300ms | easeInOut |
| Entrada de item | Scale + Fade | 400ms | easeOut |
| Indicador de racha | Bounce | 600ms | easeInOut |
| Like animation | Scale + Rotate | 300ms | easeOut |

---

## 📚 Guías de Implementación

### Estructura de Carpetas

```
lib/
├── core/
│   └── theme/
│       └── app_theme.dart          # Sistema de diseño completo
├── presentation/
│   ├── screens/                    # Pantallas principales
│   │   ├── home_screen.dart
│   │   ├── feed_screen.dart
│   │   ├── calendar_view.dart
│   │   └── ... (otras pantallas)
│   ├── widgets/                    # Componentes reutilizables
│   │   ├── lectura_card.dart
│   │   ├── streak_badge.dart
│   │   └── ... (otros componentes)
│   └── providers/                  # Estado con Riverpod
└── data/
    └── models/                     # Modelos de datos
```

### Cómo Usar AppTheme

```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

// Colores
backgroundColor: AppTheme.scaffoldBg,
textColor: AppTheme.textPrimary,
accentColor: AppTheme.accentGold,

// Border Radius
borderRadius: BorderRadius.circular(AppTheme.radiusMedium),

// Sombras
boxShadow: AppTheme.softShadow,

// Gradientes
decoration: BoxDecoration(
  gradient: AppTheme.headerGradient,
),

// Tipografía
style: Theme.of(context).textTheme.headlineLarge,
```

### Crear Componentes Personalizados

```dart
// Ejemplo: Crear un componente de lectura card
class LecturaCard extends StatelessWidget {
  final String referencia;
  final String texto;
  final VoidCallback onRead;
  final VoidCallback onMark;

  const LecturaCard({
    required this.referencia,
    required this.texto,
    required this.onRead,
    required this.onMark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.softShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              referencia,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              texto,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: onRead, child: const Text('Leer')),
                ElevatedButton(onPressed: onMark, child: const Text('✓')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Temas Oscuro (Futuro)

Aunque actualmente la app usa tema claro, la estructura soporta tema oscuro:

```dart
// app_theme.dart - Agregar método para tema oscuro
static ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF121212),
    // ... resto de configuración
  );
}
```

### Accesibilidad

**Directrices:**
1. Relación de contraste mínimo 4.5:1 para texto pequeño
2. Relación 3:1 para elementos gráficos grandes
3. Tamaño mínimo de tap target: 48x48 dp
4. Usar `semanticLabel` en iconos

```dart
// Ejemplo accesible
IconButton(
  onPressed: () {},
  icon: const Icon(Icons.favorite),
  tooltip: 'Marcar como favorito',
  // Para screen readers
  semanticLabel: 'Marcar reflexión como favorita',
);
```

### Internacionalización (i18n)

La app usa `intl` package para traducciones:

```dart
import 'package:intl/intl.dart';

// Fechas localizadas
String formatted = DateFormat('d MMMM yyyy', 'es').format(DateTime.now());

// Números localizados
String number = NumberFormat('#,##0.00', 'es').format(1234.56);
```

---

## 🚀 Checklist de Implementación

- [ ] Configurar `app_theme.dart` como fuente única de verdad
- [ ] Crear componentes base reutilizables
- [ ] Implementar responsividad en todas las pantallas
- [ ] Agregar transiciones y animaciones
- [ ] Validar contraste de colores (WCAG AA)
- [ ] Probar en diferentes dispositivos
- [ ] Documentar cambios de diseño
- [ ] Revisar accesibilidad con lectores de pantalla
- [ ] Optimizar rendimiento de animaciones
- [ ] Crear guía de estilos visual

---

## 📞 Referencias

- **Design Framework**: Material Design 3
- **Fuente**: Google Fonts - Inter
- **Gestión de Estado**: Riverpod
- **Backend**: Firebase
- **Notificaciones**: flutter_local_notifications
- **Autenticación**: Firebase Auth + Google Sign-In

---

**Última actualización**: Junio 2026  
**Versión de diseño**: 1.0  
**Compatibilidad**: Flutter 3.5+, Material Design 3
