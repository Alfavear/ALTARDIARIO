// Herramienta administrativa (NO es una Cloud Function) para mover los datos
// privados del perfil público a `usuarios/{uid}/private/account`.
//
// Uso, con la cuenta de servicio del proyecto en GOOGLE_APPLICATION_CREDENTIALS:
//   cd functions
//   npm run migrate:private-account -- --project altardiario-ec25f           # informe, no escribe
//   npm run migrate:private-account -- --project altardiario-ec25f --apply   # ejecuta
//
// Por defecto NO toca nada: hace falta `--apply` para escribir. El script es
// idempotente (se puede repetir) y va por lotes para no cargar el proyecto.
//
// Ver `docs/SECURITY.md` para el orden de operaciones completo.

import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore, type DocumentData, type QueryDocumentSnapshot } from 'firebase-admin/firestore';
import { planMigracion, type Documento } from './privateAccount';

const PAGINA = 200;

function arg(nombre: string): string | undefined {
  const i = process.argv.indexOf(`--${nombre}`);
  return i >= 0 ? process.argv[i + 1] : undefined;
}

async function main(): Promise<void> {
  const projectId = arg('project') ?? process.env.GCLOUD_PROJECT ?? 'altardiario-ec25f';
  const aplicar = process.argv.includes('--apply');
  const limite = Number(arg('limit') ?? '0') || 0;

  initializeApp({ projectId });

  const db = getFirestore();
  const usuarios = db.collection('usuarios');

  let cursor: QueryDocumentSnapshot<DocumentData> | undefined;
  let escaneados = 0;
  let migrados = 0;
  let omitidos = 0;
  let errores = 0;

  for (;;) {
    let consulta = usuarios.limit(PAGINA);
    if (cursor) consulta = consulta.startAfter(cursor);
    const pagina = await consulta.get();
    if (pagina.empty) break;
    cursor = pagina.docs[pagina.docs.length - 1];

    for (const doc of pagina.docs) {
      escaneados++;
      const publico = doc.data() as Documento;
      const privadoSnap = await doc.ref.collection('private').doc('account').get();
      const privado = (privadoSnap.exists ? privadoSnap.data() : {}) as Documento;

      const plan = planMigracion(doc.id, publico, privado);
      if (!plan) continue;
      omitidos += plan.omitidos.length;

      if (!aplicar) {
        migrados++;
        continue;
      }

      try {
        const copiar: Record<string, unknown> = {};
        for (const campo of plan.borrar) {
          if (campo in plan.copiar) copiar[campo] = plan.copiar[campo];
        }
        if (Object.keys(copiar).length > 0) {
          await doc.ref.collection('private').doc('account').set(copiar, { merge: true });
        }
        const update: Record<string, unknown> = {};
        for (const campo of plan.borrar) update[campo] = FieldValue.delete();
        await doc.ref.update(update);
        migrados++;
      } catch (error) {
        errores++;
        console.error(`x ${doc.id}: ${(error as Error).message}`);
      }
    }

    if (limite && escaneados >= limite) break;
  }

  console.log('');
  console.log(aplicar ? 'Migracion aplicada' : 'Informe (sin cambios: anade --apply para escribir)');
  console.log(`  perfiles escaneados: ${escaneados}`);
  console.log(`  perfiles con datos privados: ${migrados}`);
  console.log(`  campos omitidos (el documento privado ya tenia el valor): ${omitidos}`);
  console.log(`  errores: ${errores}`);
  if (errores > 0) process.exitCode = 1;
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
