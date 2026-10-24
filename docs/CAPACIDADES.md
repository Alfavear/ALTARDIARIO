# Capacidades por sesión: skills, MCPs, plugins y agentes

> Qué herramientas tiene cada una de las tres sesiones, quién hace UX/UI y cómo se aplica.
> Complementa `docs/FLUJO.md` (carriles) y `docs/SESIONES_ARRANQUE.md` (cómo arrancar).

## Por qué separarlas

En este PC OpenCode ve **unas 118 skills únicas**: 67 globales (`~/.config/opencode/skills`: Angular, Rails,
Salesforce, C++…), 17 del proyecto (`.opencode/skills`), 11 de `~/.agents/skills`, las del plugin `superpowers`
y las de `~/.claude/skills`. Con las tres sesiones en la misma máquina, todas cargaban todas. Eso gasta contexto,
confunde la elección de herramienta y deja que una sesión use cosas que no son de su carril (p. ej. diseñar o
escribir el roadmap). Cada sesión recibe solo lo suyo.

## Reparto

| | **Integradora** (`i/…`) | **Plataforma** (`a/…`) | **Producto / UX-UI** (`b/…`) |
|---|---|---|---|
| **Misión** | Integrar, mantener el roadmap, auditar | Reglas, CI, funciones, seguridad | Pantallas, diseño, experiencia, i18n |
| **Skills de proyecto** | autonomous-loop, architecture, release, testing | firestore-rules, firebase-firestore, firebase-emulator, observability, architecture, testing | flutter-screen, flutter-model, flutter-riverpod, flutter-performance, flutter-test, feature-scaffold, i18n, social-features, architecture, testing, **frontend-design** |
| **Skills globales** | code-reviewer, code-documenter, spec-miner, feature-forge, the-fool, architecture-designer, domain-modeling | security-reviewer, secure-code-guardian, devops-engineer, monitoring-expert, debugging-wizard, test-master, mcp-developer | **web-design-guidelines**, flutter-expert, flutter-apply-architecture-best-practices, feature-forge, domain-modeling, test-master, debugging-wizard, **playwright-expert**, **webapp-testing** |
| **MCPs** | `roadmap` (única que escribe `tasks.yaml`), `context7`, `knowledge-graph-memory` | `context7`, `fetch`, `knowledge-graph-memory` | **`stitch`**, **`playwright`**, `context7`, `knowledge-graph-memory` |
| **Plugin `superpowers`** | no | no | sí (brainstorming y TDD ayudan a iterar UI) |
| **Agentes** | reviewer, auditor, release-manager, planner | rules-auditor, tester, reviewer, fixer, implementer | planner, implementer, tester, reviewer, fixer |
| **GitHub** | app `altardiario-integradora` | app `altardiario-plataforma` | app `altardiario-producto` |

Nada más está disponible en esa sesión. Las skills de otros lenguajes (Angular, Django, Rails, C++, Salesforce…)
no las usa ninguna.

## Quién hace UX/UI: la sesión Producto

Es la **única sesión de diseño**. Las otras dos no diseñan ni aprueban cambios visuales.

Flujo de una pantalla nueva o rediseñada:

1. **Fuente de verdad visual:** `DESIGN.md` (tokens de color, tipografía, espaciado, estados). Si falta un token, se
   añade ahí primero, en el mismo PR.
2. **Dirección y exploración:** skill `frontend-design` y, si hay que explorar variantes, el MCP **`stitch`**
   (diseño → código; requiere `GOOGLE_STITCH_API_KEY` en el entorno de la sesión Producto).
3. **Implementación:** `flutter-screen` / `flutter-riverpod`, con los componentes de estado de
   `lib/presentation/widgets/estados/` (carga, vacío, error con reintento).
4. **Revisión de accesibilidad y guías:** skill `web-design-guidelines` sobre el diff.
5. **Comprobación visual:** `flutter build web` + MCP **`playwright`** (capturas y recorrido del flujo). La skill
   `webapp-testing` guía el uso.
6. **Textos:** nada pegado en el widget; skill `i18n` (ARB es/en).

Cambios de `DESIGN.md` o de tokens globales: un solo PR vivo a la vez (fichero compartido).

## Lo que cada sesión NO tiene, y por qué

- **Roadmap MCP solo en la Integradora.** El estado de quién hace qué lo da GitHub (`node scripts/board.mjs`);
  `tasks.yaml` lo cierra la Integradora al mergear. Plataforma y Producto no escriben el roadmap.
  *Consecuencia:* el agente `orchestrator` y `/cycle` dependen de ese MCP y hoy no encajan en Plataforma ni en
  Producto. Pendiente: **T-062**.
- **Playwright y Stitch solo en Producto**, y **fetch solo en Plataforma**: son las únicas que los necesitan.
- **`superpowers` solo en Producto.** Su flujo propio (planes, worktrees por su cuenta) choca con
  `docs/FLUJO.md` en las otras dos. Si un día se quiere en todas, hay que alinear antes su skill de worktrees
  con `scripts/nueva-sesion.sh`.

## Cómo se aplica

```bash
scripts/nueva-sesion.sh producto T-054 borrado-de-cuenta
```

Crea `…\sesiones\producto\opencode.jsonc` (la plantilla de `.opencode/sesiones/producto.jsonc`) y el worktree
`…\sesiones\producto\T-054-borrado-de-cuenta\` desde `origin/main`, con la identidad de la app. **Abre OpenCode en
la carpeta del worktree.** OpenCode busca `opencode.jsonc` desde el directorio de trabajo hacia arriba, así que el
de la carpeta de la sesión aplica a todos sus worktrees y no a los de las demás.

Las plantillas usan `policies` (`integration.use` sobre `skill:`, `mcp:` y `plugin:`): primero se niega en bloque y
después se permite lo del carril, porque gana la última regla que coincide.

## Prueba de humo (2 minutos, obligatoria la primera vez)

No se ha podido verificar por ejecución: la CLI no se puede lanzar sin interfaz y la app de escritorio 2.1.4 es la
única versión instalada. En cada sesión nueva, pregunta:

> Lista exactamente las skills, los MCPs y los plugins que tienes disponibles. No uses ninguno todavía.

Debe coincidir con su columna de la tabla. Si aparecen más (por ejemplo skills de Angular), la configuración de la
carpeta de sesión no se está aplicando:

1. Confirma que abriste OpenCode **dentro** del worktree y que existe `…\sesiones\<sesion>\opencode.jsonc`.
2. Compara los IDs con los de las carpetas de las skills (`ls ~/.config/opencode/skills`).
3. Revisa el log de OpenCode (`~/.local/share/opencode/log/`) por reglas de `policies` descartadas.
4. Anótalo como bloqueo **con la línea del log** (regla de `docs/FLUJO.md`) y avisa a la Integradora.

Límites conocidos de la documentación de OpenCode V2: las `policies` son globales, no por agente, y la config del
repositorio es la de menor precedencia (no puede reactivar lo que una config más alta niegue). Por eso la
separación va **por carpeta de sesión** y no por agente.

## Mantenimiento

- Añadir o quitar una skill/MCP de una sesión: editar `.opencode/sesiones/<sesion>.jsonc` en un PR de Plataforma y
  repetir la prueba de humo. Las carpetas de sesión ya creadas conservan su copia: `scripts/nueva-sesion.sh` avisa
  si difiere de la plantilla.
- Una skill duplicada (`frontend-design` existe en `.opencode/skills` y en `~/.agents/skills`) comparte ID: no se
  puede elegir cuál carga. Si divergen, renombrar una de las dos.
- Ninguna clave va en estas plantillas. `GOOGLE_STITCH_API_KEY` y las claves de las apps viven en el entorno y en
  `~/.altardiario-keys/`.
