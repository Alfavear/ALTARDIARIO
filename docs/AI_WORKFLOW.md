# Trabajar día a día con OpenCode en AltarDiario

## Primer día
```bash
git clone https://github.com/Alfavear/ALTARDIARIO.git && cd ALTARDIARIO
git checkout feat/andamiaje-internacional   # hasta que se mergee en main
scripts/bootstrap.sh                         # deps, .env, hook pre-commit
opencode                                     # arranca el agente en el repo
```
Si OpenCode avisa de que `opencode.jsonc` tiene claves desconocidas, tu
versión es V1: actualiza (`opencode upgrade`) o consulta la nota de migración
en https://opencode.ai/v2/docs/migrate-v1.

## Un ciclo típico
1. Escribe el issue en GitHub con la plantilla **Feature** (contexto, criterios
   de aceptación, fuera de alcance, pistas). Esto es lo que más determina la
   calidad del resultado.
2. En OpenCode: `/feature #42` (o pega el texto). El agente planifica con
   `planner`, implementa, corre `/check`, se autorrevisa con `reviewer`, y
   commitea en una rama. No hace push.
3. Lee el resumen y el informe del reviewer. Si estás conforme: `git push` y
   abre el PR. La CI corre lo mismo que `scripts/check.sh`.
4. Mergea. Si cambiaron reglas/índices/web, `deploy-firebase.yml` despliega.

## Modo autónomo (la app se mejora sola)

```bash
scripts/loop.sh 3                 # corre 3 ciclos; cada uno: tarea → implementa → check → review → bitácora
node tools/roadmap-mcp/cli.mjs state
git branch --list 'auto/*'        # ramas listas para PR
```
Cada ciclo toma la siguiente tarea de `roadmap/tasks.yaml`, la ejecuta con el
pipeline planner → implementer → tester → reviewer → fixer, y registra todo en
`roadmap/BITACORA.md`. Cada 5 ciclos (o si el backlog se vacía) el `auditor`
revisa el repo y crea tareas nuevas. El bucle para solo si: alcanza N, falla
dos veces en la misma tarea, no hay tareas tras auditar, o creas `roadmap/STOP`.

Tú: revisas ramas `auto/*`, abres PRs, resuelves tareas `blocked` (deploys,
decisiones de producto, secretos) y ajustas prioridades en `tasks.yaml`.
Detalles: skill `autonomous-loop`.

## Comandos útiles
| Comando | Qué hace |
|---|---|
| `/cycle` | un ciclo autónomo completo |
| `/audit` | auditoría en 6 dimensiones → tareas |
| `/roadmap [T-xxx]` | estado del roadmap / detalle de tarea |
| Comando | Qué hace |
|---|---|
| `/check` | format + analyze + test, y arregla lo que falle |
| `/rules-test` | tests de reglas con emulador |
| `/review [rama]` | informe del reviewer, sin editar nada |
| `/migrate-feature oracion` | mueve una feature a `lib/features/` |
| `/audit-security` | auditoría completa |
| `/release [X.Y.Z]` | prepara release; pide confirmación para tag/push |

## Qué tareas delegar bien al agente
- Tests nuevos para código existente (modelos, servicios, reglas).
- Migraciones mecánicas (`/migrate-feature`), partir archivos grandes.
- Features con criterios claros y acotados (una pantalla, un provider).
- Documentación y CHANGELOG.

## Qué mantener en manos humanas
- Decisiones de producto y de UX (qué construir, no cómo).
- Deploy de reglas a producción y releases a tiendas.
- Cualquier cambio en `firebase_options.dart`, secretos, facturación.
- Revisar que un refactor no cambió comportamiento visible (prueba la app).

## Consejos
- Un issue = un PR = una cosa. Si el plan del `planner` supera 6 archivos, divide.
- Pide siempre "pega la salida de scripts/check.sh". Si el agente no la pega, no está hecho.
- Cuando el agente se equivoque de forma repetida, la solución no es repetir la
  instrucción en el chat: es añadirla a `AGENTS.md` o a la skill correspondiente.
- Mantén `docs/adr/` al día; el agente los lee y evita rediscutir lo decidido.
