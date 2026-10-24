# Registro de sesiones

Un **fichero por sesión**, nunca uno compartido: así dos sesiones no se pisan al
escribir. La orquestadora los lee y los agrega en `ESTADO-A.md` / `ESTADO-B.md`.

## Cómo usarlo

1. Al empezar, copia `PLANTILLA.md` a `<rol>-<letra>.md` (p. ej. `implementadora-b.md`).
2. Rellena: worktree, rama, PR, **SHA de `origin/main` contra el que trabajas** y
   siguiente paso.
3. Actualízalo cada ~30 min y **al terminar**.
4. Si te vas sin actualizarlo, la siguiente sesión no sabe si sigues vivo o
   abandonaste: eso es exactamente lo que lleva a duplicar trabajo.

## Convención de nombres

| Fichero | Quién |
|---|---|
| `orquestadora-a.md` | la única sesión que mergea y escribe el roadmap |
| `implementadora-b.md` | la sesión que abre PRs del carril B |
| `auditora-<tema>.md` | sesiones de solo lectura (seguridad, rendimiento, UX…) |
| `humano.md` | si alguien trabaja a mano en el repo |

Si abres una cuarta sesión, su fichero debe declarar qué conjunto de ficheros toca
y confirmar que no se solapa con los demás.

## Regla dura

Un fichero de sesión sin latido en las últimas **6 horas** se considera abandonado:
su rama no se borra, pero su trabajo pasa a ser reclamable por otra sesión,
avisando en el PR. Nunca se borra una rama con trabajo sin push.
