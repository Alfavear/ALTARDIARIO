---
name: frontend-design
description: Usar al crear, modificar o revisar cualquier pantalla, widget o flujo de UI (Flutter o web), o al auditar ergonomía, accesibilidad, contraste, touch targets, overflow, estados vacío/carga/error o microcopia.
---

# Protocolo de diseño frontend y UI/UX (anti-slop)

Antes de escribir UI, lee `DESIGN.md` y usa los tokens de `lib/core/theme/app_theme.dart`.
Nunca inventes un color, radio o margen: si el token no existe, se añade a `AppTheme`, no inline.

## Fase 1 — Flujo y ergonomía

- **Zona del pulgar (móvil):** acciones principales en el tercio inferior; destructivas
  (eliminar, cerrar sesión, salir de grupo) fuera del alcance accidental y con confirmación.
- **Carga cognitiva:** una sola acción principal por vista. Jerarquía:
  `FilledButton`/`ElevatedButton` para la principal, `OutlinedButton`/`TextButton` para el resto.
  Si hay dos botones rellenos compitiendo, la pantalla está mal.
- **Prevención de errores:** validación en vivo mientras se escribe, no al pulsar enviar.
  Mensajes específicos junto al campo ("El correo no tiene @"), nunca un alert genérico.
  En formularios, el botón de envío permanece deshabilitado hasta que el formulario es válido.
- **Teclado:** el teclado no puede tapar el campo enfocado ni el botón de envío
  (`SingleChildScrollView` + `resizeToAvoidBottomInset`, o el campo hace `ensureVisible`).
- **Scroll:** listas con `ListView.builder`/`.separated`; nunca `Column` dentro de un `SingleChildScrollView` con hijos dinámicos.

## Fase 2 — Microcopia (UX writing)

- Prohibido el texto técnico en la interfaz: nada de `Exception`, `null`, `Firestore`, `Error 500`, `PERMISSION_DENIED`, stack traces.
- Cada error dice **qué pasó + qué hacer**, en segunda persona:
  "No pudimos conectar. Revisa tu conexión e inténtalo de nuevo."
  "No tienes permiso para ver esta publicación."
- Estados vacíos: explican qué es la pantalla y ofrecen la acción inicial, no solo "Sin datos".
- Botones con verbo: "Guardar reflexión", no "Aceptar" ni "OK".

## Fase 3 — Validación visual

1. Si hay servidor local, usa Playwright: screenshot a 1440px y 375px.
2. Revisa overflow de texto, alineaciones rotas, botones tapados y contraste antes de terminar.
3. En Flutter, prueba con `MediaQuery.textScalerOf` al 200%: si el texto rompe el layout, no está hecho.

## Checklist de entrega

- [ ] Touch target ≥ 48×48 dp en todo elemento interactivo.
- [ ] Los 4 estados declarados: datos, carga (skeleton/spinner no bloqueante),
      error (texto comprensible + botón de reintento), vacío (icono + texto + CTA).
- [ ] Contraste WCAG AA: 4.5:1 texto normal, 3:1 texto grande y elementos gráficos.
- [ ] Ningún espaciado fuera de la escala de `DESIGN.md` (4/8/12/16/24/32/48).
- [ ] Jerarquía por tamaño y contraste, no solo por `fontWeight`.
- [ ] Teclado visible sin tapar campos; foco visible (nunca `outline: none` huérfano).
- [ ] `semanticLabel`/`tooltip` en iconos sin texto.

## Anti-patrones que rechazas

| Anti-patrón | Corrección |
|---|---|
| Hex suelto en un widget | Token de `AppTheme` |
| `padding: 13px`, `SizedBox(height: 11)` | Escala de 4/8 |
| Dos CTA rellenos en la misma vista | Uno primario, resto outlined/text |
| `CircularProgressIndicator` a pantalla completa | Skeleton del contenido |
| `catch` que muestra "Error" | Mensaje accionable + reintento |
| Estado vacío con "No hay datos" | Explicación + acción inicial |
