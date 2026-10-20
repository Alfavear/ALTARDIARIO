# ADR-0002: Gamificación y rachas en servidor

**Estado:** Aceptada (adopción gradual) · **Fecha:** 2026-10-19

## Contexto
`gamification_service.dart` calcula XP, insignias y nivel en el cliente y los
escribe en `usuarios/{uid}`. Las rachas viven en `shared_preferences`. Las
reglas permiten al dueño escribir su propio perfil. Consecuencias: el ranking
es falsificable con una petición manual, las rachas se pierden al reinstalar
y no sincronizan entre dispositivos.

## Decisión
La fuente de verdad de `totalPuntos`, `nivel`, `badges` y `rachaActual` pasa a
Cloud Functions (`functions/src/gamification.ts`), que reaccionan a eventos
reales (documentos creados, lecturas marcadas en `usuarios/{uid}/lecturas/{fecha}`).

Adopción en tres pasos, cada uno un PR:
1. Desplegar functions en paralelo. El cliente sigue escribiendo; comparar en
   Analytics/consola que los valores coinciden.
2. El cliente deja de escribir esos campos; solo los lee. `gamification_service.dart`
   queda como calculadora de "qué insignia estás a punto de ganar" (UI).
3. Añadir a `firestore.rules` (rama dueño de `/usuarios`):
   `&& !changedKeys().hasAny(['totalPuntos','badges','nivel','rachaActual'])`
   con su test. A partir de aquí el ranking es confiable.

Las lecturas diarias se registran en `usuarios/{uid}/lecturas/{yyyy-mm-dd}`
(idempotente) y una function diaria recalcula rachas y materializa
`leaderboards/global` y `leaderboards/{uid}_amigos` para eliminar `getAllUsuarios()`.

## Consecuencias
- Requiere plan Blaze (coste ~0 a esta escala).
- Latencia de XP: ~1-2 s (aceptable; la UI puede mostrar optimista).
- Las insignias dejan de poder "inventarse" en cliente; cualquier insignia nueva
  se define en el servidor y el cliente solo la renderiza.
