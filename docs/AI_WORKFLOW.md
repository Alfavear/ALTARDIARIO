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

## Comandos útiles
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
