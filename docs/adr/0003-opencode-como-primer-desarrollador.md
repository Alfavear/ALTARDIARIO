# ADR-0003: OpenCode como primer desarrollador

**Estado:** Aceptada · **Fecha:** 2026-10-19

## Contexto
El proyecto lo mantiene una persona con ayuda de agentes de IA. Un agente
rinde en proporción a (a) cuán acotado está el contexto que necesita cargar,
(b) si puede verificar su propio trabajo, y (c) si hay puertas que impidan que
un error llegue a producción.

## Decisión
- `AGENTS.md` es el contrato: ciclo de trabajo, definición de hecho, límites.
- `scripts/check.sh` es la única verdad de "está bien": lo corre el agente, el
  hook pre-commit y la CI. Si difieren, se arregla el script.
- Agentes con permisos mínimos: `planner` y `reviewer` no editan; `rules-auditor`
  solo toca reglas y sus tests; `release-manager` solo versión y CHANGELOG.
  Todo push/deploy/build de tienda pide confirmación humana.
- Los issues se escriben con criterios de aceptación verificables; un issue sin
  ellos vuelve al humano antes de escribir código.
- La CI es el juez de los PRs; el humano revisa diseño y producto, no formato.

## Consecuencias
- Más inversión inicial en issues bien escritos; mucho menos tiempo revisando.
- Las decisiones de arquitectura se documentan como ADR para que el agente
  pueda citarlas en vez de reinventarlas en cada sesión.
