## Qué cambia

<!-- Una o dos frases. Enlaza el issue: Closes #123 -->

## Por qué

<!-- El problema que resuelve, no la solución. -->

## Cómo se probó

- [ ] `scripts/check.sh` en verde localmente
- [ ] Tests nuevos para el comportamiento nuevo (unit / widget / reglas)
- [ ] Probado en dispositivo o emulador: <!-- Android / iOS / Web -->

## Checklist de seguridad y producto

- [ ] No toca `firestore.rules` **o** añade/actualiza tests en `firestore-tests/`
- [ ] No expone datos de un usuario a otro
- [ ] Textos nuevos listos para i18n (sin strings pegados en widgets si la pantalla ya está migrada)
- [ ] Sin archivos > 400 líneas nuevos (si lo hay, justificar)
- [ ] `CHANGELOG.md` actualizado en `[Unreleased]`

## Capturas (si cambia UI)
