# Auditoría de arquitectura y proceso multi-sesión — 2026-10-24

Alcance: infraestructura de trabajo (roadmap, sesiones orquestadora/A/B, agentes
OpenCode, scripts, CI, hooks, higiene del repo) y las zonas del código que la
condicionan. Base: `origin/main` + PR #65. Todo lo que sigue está contrastado con
ficheros, logs de CI o `git`; lo no verificado se marca como *hipótesis*.

## 1. Veredicto

El andamiaje es **ambicioso y en buena parte correcto** (check.sh como puerta única,
hook, CI con filtro de Android, MCP de roadmap, ADRs, tests de reglas con emulador).
El problema no es falta de proceso sino **exceso de proceso con varias fuentes de
verdad que se desincronizan**, y un cuello de botella humano/orquestador que genera
conflictos de integración. Síntomas reales de esta semana:

| Síntoma | Evidencia |
|---|---|
| El Ciclo 11 diagnosticó "el emulador no arranca" sin leer el log | El log real: `Error compiling rules: L70:7 Unexpected 'let'`. El emulador arrancaba bien (arreglado en PR #65) |
| El roadmap miente | `main:tasks.yaml` marca T-007, T-026, T-040, T-041, T-042, T-049 como `backlog` con PRs ya abiertos/mergeados; `STATE.md` dice "Ciclo 10, 22/53"; `BANDEJA.md` dice T-041 `in_progress` |
| Daño por auto-merge repetido | Bitácora ciclos 8-10 (métodos duplicados, llave perdida, base vieja que revertía un fix) y de nuevo en #65 (cuerpo huérfano de `counterDeltaOk`, `}` final perdido, CHANGELOG en conflicto) |
| Las sesiones invaden carriles | PR #65 es `fix/lane-b-24-*` pero hace tareas de seguridad de reglas (carril A, "bloqueado") |
| El hook empuja a saltárselo | `pre-commit` = `check.sh --fast` = pub get + format + analyze + **suite completa de tests**; en Windows sin Modo desarrollador falla por symlinks y la salida natural es `--no-verify` |
| CI en rojo permanente en `main` | `Knowledge Graph Sync` falla en cada push a `main` (run 40008375093, exit 1) |

## 2. Hallazgos

### P1 — Proceso

**H1. Fuentes de verdad fragmentadas y mutables.** El estado de una tarea vive en
`tasks.yaml`, `STATE.md`, `BANDEJA.md`, `ESTADO-A.md`, `ESTADO-B.md`, `BROADCAST.md`,
`BLOQUEANTES.md`, dos `BITACORA.md` (raíz y `roadmap/`), más `roadmap/sesiones/*.md`.
Solo la orquestadora escribe `tasks.yaml` ⇒ cualquier retraso suyo deja el roadmap
obsoleto, y todo ese estado es texto mergeado a mano por agentes.
*Causa raíz*: se guarda **estado derivado** (quién hace qué, en qué PR) en ficheros
cuando GitHub ya lo sabe de forma autoritativa (PRs, ramas, checks).

**H2. Dos protocolos de sesiones que se contradicen.** `docs/SESIONES.md` (largo,
con casos reales) y `roadmap/sesiones/GUIA_ORQUESTADOR.md` + `PROMPT_SESIONES.md`.
La guía dice "No esperes confirmación humana … actúa automáticamente mientras
`check.sh --fast` esté verde", pero `--fast` **omite los tests de reglas** y
`CODEOWNERS` asigna reglas/workflows/pubspec a un humano. Un merge automático de
`firestore.rules` solo pasa por la CI, no por un gate local ni humano.

**H3. Carriles definidos por "tipo de tarea", no por propiedad de ficheros.** A =
seguridad/core, B = UI. Pero ambos tocan `firestore_service.dart`, `firestore.rules`,
`app_providers.dart` y `CHANGELOG.md`. Los conflictos son consecuencia directa.

**H4. Diagnóstico sin evidencia.** Un informe declaró bloqueo por infraestructura sin
abrir el log, y `rules_test.sh` figura "no probado en este entorno" cuando el
equipo tiene Java 21 y el emulador funciona en local. Falta una regla: *un bloqueo
se reporta con la línea de log que lo prueba*.

### P1 — Calidad y seguridad

**H5. Los errores de sintaxis de reglas solo se ven en CI.** `--fast` salta el
emulador. Las reglas son la zona de mayor riesgo (privacidad, App Store) y la única
con ciclo de feedback de ~5 min en remoto.

**H6. Hook demasiado pesado.** Mezcla "barato y determinista" (format, analyze) con
"lento" (tests completos). Resultado: se salta. Existe `scripts/fast-lint.mjs` sin
usar como pre-commit.

**H7. `Knowledge Graph Sync` falla en `main` en cada push** y `autonomous-cycle.yml`
está desactivado con `if: false`. Un rojo crónico enseña a ignorar los rojos.

### P2 — Arquitectura de código (la que alimenta los conflictos)

**H8. Estructura dual a medias.** ADR-0001 (feature-first) completado 2/8: conviven
`lib/data + lib/presentation` con `lib/features/*`. Ficheros-dios: `perfil_screen`
2094 líneas, `bible_reader_screen` 1647, `feed_screen` 1094, `firestore_service`
964 (un solo servicio para todo Firestore), `app_providers` 661. 30 ficheros de test
para 74 de `lib`. Cada tarea de cualquier carril toca los mismos 4-5 ficheros.

**H9. `firestore.rules` monolítico** (~420 líneas) y `CHANGELOG.md` de una sola
sección "Unreleased": ambos son imanes de conflicto.

### P3 — Higiene

**H10.** 6 worktrees repartidos en `~/.codex`, `~/.local/share/opencode` y `D:\`
sin inventario (uno en HEAD desacoplado); 85 ramas locales / 77 remotas; `build/`
de 13 GB; dos APK sueltos (121 MB, ignorados pero en la raíz); scripts huérfanos sin
trackear en la raíz (`apply_changes.py`, `fix_profile.py`, `bandeja_clean.txt`); un
`.xlsx` versionado; el checkout principal está sobre una rama de feature con cambios
sin commitear (rompe la regla propia "un worktree por sesión, main limpio").

**H11. Documentación para agentes redundante**: `AGENTS.md` (233) + `SYSTEM.md`
(379) + `docs/AI_WORKFLOW.md` + `docs/SESIONES.md` + `roadmap/sesiones/*` +
`.opencode/agents/*` + `.opencode/skills/*` (17). Cada sesión paga ese contexto y
las versiones divergen (hay erratas como "Orgestrador" propagadas). `docs/ROADMAP.md`,
`docs/PRODUCT_EVOLUTION_ROADMAP.md` y `tasks.yaml` describen tres veces el mismo plan.

## 3. Arquitectura objetivo

Principio rector: **un dato, un dueño; el estado volátil lo guarda GitHub, no ficheros.**

```
GitHub (autoritativo, volátil)      Repo (declarativo, estable)
─────────────────────────────       ───────────────────────────
PR draft  = claim/lease de tarea    roadmap/tasks.yaml  = QUÉ (definición, criterios,
PR/branch name contiene T-xxx         prioridad). Sin campos de estado volátil.
labels: ready, blocked, human       docs/adr/*          = decisiones
checks    = veredicto de calidad    AGENTS.md (≤120 l.) = router único hacia lo demás
merge queue / auto-merge            ownership.yaml      = carril → rutas
        │                                  │
        └──────► scripts/board.mjs ◄───────┘
                 (lee ambos, genera tablero; NO se commitea)
```

**Estado derivado, no escrito.** `scripts/board.mjs` (`gh pr list` + `tasks.yaml`)
imprime el tablero real: tarea → PR → checks → bloqueos. Desaparecen `STATE.md`,
`BANDEJA.md`, `ESTADO-A/B.md`, `BROADCAST.md`, `roadmap/sesiones/*` y la mutación
manual de estados. `tasks.yaml` pasa a ser backlog de lectura; el `status: done` lo
pone un job al mergear (PR con `T-xxx` en el título), no una sesión.

**Carriles por propiedad de rutas (`ownership.yaml`)**, validado por un check de CI:

| Carril | Rutas | Regla |
|---|---|---|
| Plataforma/Seguridad (A) | `firestore.rules`, `firestore-tests/`, `functions/`, `.github/`, `scripts/`, `lib/core/` | Humano obligatorio (CODEOWNERS + "require review from code owners") |
| Producto (B) | `lib/features/**`, `lib/presentation/**`, `assets/`, `l10n` | Auto-merge si checks verdes |
| Compartidas (`firestore_service`, `app_providers`, modelos) | — | Cambio **contract-first**: PR pequeño a `main` antes de que cualquier carril construya encima; nunca dos PRs vivos sobre el mismo fichero |

Si un PR del carril B toca rutas de A, el check lo etiqueta `needs-human` y lo
bloquea hasta que lo vea el dueño. Eso habría parado #65 como "fuera de carril".

**Puertas por niveles (costes crecientes, se salta menos lo barato):**

| Nivel | Dónde | Contenido | Tiempo |
|---|---|---|---|
| 0 | pre-commit | `dart format` + `flutter analyze` (+ `fast-lint.mjs`) | <30 s |
| 1 | pre-push | tests Flutter **y**, si el diff toca `firestore.rules`/`firestore-tests`, `rules_test.sh` completo | 2-4 min |
| 2 | CI PR | lo actual + check de "diff dentro del carril" + validación de `firestore.indexes.json` | ~5 min |
| 3 | merge queue | re-ejecuta nivel 2 sobre el resultado del merge | — |

**Reglas de un solo sitio.** Un bloqueo se reporta **con la línea de log** (`gh run
view --log-failed | grep`). Un `--no-verify` requiere nota en el PR.

**Reducir conflictos estructuralmente** (lo que de verdad baja el coste de integrar):
1. `CHANGELOG`: fragmentos `changelog.d/T-xxx.md` y un script que los compone al
   release → desaparece el conflicto más repetido.
2. Dividir `FirestoreService` por feature (continuar ADR-0001): `ReflexionRepository`,
   `OracionRepository`, `ChatRepository`, `UsuarioRepository`… detrás de interfaces
   existentes; los carriles dejan de compartir un fichero de 964 líneas.
3. `firestore.rules` por secciones en `firestore-tests/rules/*.rules` con un
   `scripts/build_rules.mjs` que las concatena (Firestore no admite imports) y un
   test que verifica que el artefacto generado está al día.
4. Trocear `perfil_screen` y `bible_reader_screen` en widgets por feature.

## 4. Plan de migración (por riesgo y colisión)

**Fase 0 — hoy, sin tocar lo que las sesiones editan** (no colisiona):
- [ ] Arreglar/retirar `Knowledge Graph Sync` (en rojo en `main`): causa concreta del exit 1.
- [ ] Hook: pre-commit ligero (nivel 0) + pre-push (nivel 1) con detección de cambios en reglas.
- [ ] `scripts/hygiene.sh`: lista worktrees, ramas mergeadas y tamaño de `build/`; borrado solo con `--apply`.
- [ ] Mover fuera de la raíz APKs/xlsx/scripts huérfanos; limpiar la rama del checkout principal.
- [ ] `docs/`: una sola nota "estado de verdad" apuntando a este esquema.

**Fase 1 — congelar y migrar el tablero** (requiere pausar las 3 sesiones ~1 h):
- [ ] `scripts/board.mjs` + job que marca `done` al mergear; archivar `STATE/BANDEJA/ESTADO-*/BROADCAST/sesiones` en `roadmap/archive/`.
- [ ] `ownership.yaml` + check de CI + "require code owners" para rutas de A.
- [ ] Fusionar `docs/SESIONES.md` + `GUIA_ORQUESTADOR.md` + `PROMPT_SESIONES.md` en una sola guía (≤1 página) y recortar `AGENTS.md`.
- [ ] Corregir `STATE`/`tasks.yaml` una última vez a mano contra los PRs reales.

**Fase 2 — estructural, tarea a tarea (ya en backlog como fase 3):**
- [ ] `changelog.d/`, reglas por secciones, repositorios por feature, troceo de pantallas.

## 5. Riesgos del cambio

- Migrar el tablero con sesiones activas generaría justo los conflictos que se
  quieren evitar ⇒ Fase 1 solo con las sesiones pausadas.
- "Require code owners" ralentiza el carril A y depende de una sola persona
  (`@Alfavear`); añadir un segundo dueño o aceptar la latencia.
- El estado en GitHub depende de que `T-xxx` aparezca en el título del PR: se
  valida con un check, si no, el tablero se descuadra.
