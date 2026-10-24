#!/usr/bin/env node
// Script de migración del campo 'oculto' en documentos anteriores a T-026
//
// PROPÓSITO:
//   Los documentos creados antes de T-026 no tienen el campo 'oculto'.
//   Las consultas `where('oculto', '==', false)` los excluyen, dejando el feed vacío.
//   Este script pone 'oculto=false' en los que no tienen el campo,
//   y 'oculto=true' si tenían el campo legacy 'hidden: true'.
//   Es idempotente: no toca documentos que ya tienen 'oculto'.
//
// REQUISITOS:
//   - Node.js 18+
//   - firebase-admin instalado en functions/node_modules:
//       cd functions && npm install
//   - Cuenta de servicio con permisos de Firestore en GOOGLE_APPLICATION_CREDENTIALS
//     (o gcloud auth application-default login)
//
// USO (desde la raíz del repo):
//   # Simulacro (por defecto): solo cuenta, no escribe
//   node scripts/migrar-oculto.mjs --project altardiario-ec25f
//
//   # Aplicar cambios
//   node scripts/migrar-oculto.mjs --project altardiario-ec25f --aplicar
//
//   # Limitar documentos escaneados (útil para pruebas)
//   node scripts/migrar-oculto.mjs --project altardiario-ec25f --limit 100
//
// SALIDA:
//   Imprime contadores por colección y un resumen final.
//   Código de salida 0 si OK, 1 si hay errores.

import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';
import { existsSync } from 'fs';
import { createRequire } from 'module';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Configuración
const BATCH_SIZE = 400;
const PAGE_SIZE = 500;

// Colecciones a procesar
const ROOT_COLLECTIONS = [
  'reflexiones',
  'debates',
  'peticiones_oracion',
];

const COLLECTION_GROUPS = [
  'comentarios',  // subcolección de reflexiones y peticiones_oracion
  'respuestas',   // subcolección de debates
];

let admin;

async function cargarFirebaseAdmin() {
  const functionsDir = resolve(__dirname, '../functions');
  const functionsPackageJson = resolve(functionsDir, 'package.json');
  const functionsNodeModules = resolve(functionsDir, 'node_modules');

  // Verificar que functions/node_modules existe ANTES de intentar importar
  if (!existsSync(functionsNodeModules)) {
    console.error('✗ No existe functions/node_modules');
    console.error('  Ejecuta primero: cd functions && npm ci');
    console.error('  (npm ci instala las dependencias exactas del package-lock.json)');
    process.exit(1);
  }

  // Verificar que firebase-admin está instalado
  const firebaseAdminPath = resolve(functionsNodeModules, 'firebase-admin');
  if (!existsSync(firebaseAdminPath)) {
    console.error('✗ firebase-admin no está instalado en functions/node_modules');
    console.error('  Ejecuta: cd functions && npm ci');
    process.exit(1);
  }

  // Importar firebase-admin usando createRequire apuntando al package.json de functions
  // Esto resuelve las dependencias desde functions/node_modules correctamente en ESM
  const require = createRequire(functionsPackageJson);
  admin = require('firebase-admin');
}

function parseArgs() {
  const args = process.argv.slice(2);
  const result = { projectId: 'altardiario-ec25f', aplicar: false, limit: 0 };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === '--project' || arg === '-p') {
      result.projectId = args[++i];
    } else if (arg === '--aplicar' || arg === '-a') {
      result.aplicar = true;
    } else if (arg === '--limit' || arg === '-l') {
      result.limit = Number(args[++i]) || 0;
    } else if (arg === '--help' || arg === '-h') {
      printHelp();
      process.exit(0);
    }
  }
  return result;
}

function printHelp() {
  console.log(`
Uso: node scripts/migrar-oculto.mjs [opciones]

Opciones:
  --project, -p <projectId>   ID del proyecto Firebase (default: altardiario-ec25f)
  --aplicar, -a               Escribe en Firestore (por defecto solo simulacro)
  --limit, -l <número>        Límite de documentos a escanear por colección (0 = sin límite)
  --help, -h                  Muestra esta ayuda

Ejemplos:
  node scripts/migrar-oculto.mjs --project altardiario-ec25f
  node scripts/migrar-oculto.mjs --project altardiario-ec25f --aplicar
  node scripts/migrar-oculto.mjs --project altardiario-ec25f --limit 100 --aplicar
`);
}

async function procesarColeccionRaiz(db, nombreColeccion, aplicar, limiteGlobal) {
  console.log(`\n📂 Procesando colección raíz: ${nombreColeccion}`);
  const colRef = db.collection(nombreColeccion);

  let escaneados = 0;
  let actualizados = 0;
  let omitidos = 0;
  let errores = 0;
  let cursor = null;
  let batch = db.batch();
  let batchOps = 0;

  for (;;) {
    let consulta = colRef.limit(PAGE_SIZE);
    if (cursor) consulta = consulta.startAfter(cursor);

    const pagina = await consulta.get();
    if (pagina.empty) break;
    cursor = pagina.docs[pagina.docs.length - 1];

    for (const doc of pagina.docs) {
      escaneados++;
      if (limiteGlobal && escaneados > limiteGlobal) break;

      const data = doc.data();

      // Verificar si necesita migración
      const tieneOculto = 'oculto' in data;
      const hiddenTrue = data.hidden === true;

      if (tieneOculto) {
        omitidos++;
        continue;
      }

      // Necesita migración: no tiene 'oculto' o tiene 'hidden: true'
      const nuevoOculto = hiddenTrue ? true : false;

      // Contar documentos que requieren migración (tanto en simulacro como en escritura)
      actualizados++;

      if (aplicar) {
        try {
          batch.set(doc.ref, { oculto: nuevoOculto }, { merge: true });
          batchOps++;
        } catch (e) {
          errores++;
          console.error(`  ✗ Error en ${doc.id}: ${e.message}`);
        }
      }

      // Commit batch si llega al límite
      if (aplicar && batchOps >= BATCH_SIZE) {
        try {
          await batch.commit();
          batch = db.batch();
          batchOps = 0;
        } catch (e) {
          errores++;
          console.error(`  ✗ Error en commit batch: ${e.message}`);
          batch = db.batch();
          batchOps = 0;
        }
      }
    }

    if (limiteGlobal && escaneados >= limiteGlobal) break;
  }

  // Commit batch final
  if (aplicar && batchOps > 0) {
    try {
      await batch.commit();
    } catch (e) {
      errores++;
      console.error(`  ✗ Error en commit final: ${e.message}`);
    }
  }

  console.log(`  Escaneados: ${escaneados} | Actualizados: ${actualizados} | Omitidos (ya tenían oculto): ${omitidos} | Errores: ${errores}`);
  return { escaneados, actualizados, omitidos, errores };
}

async function procesarCollectionGroup(db, nombreGrupo, aplicar, limiteGlobal) {
  console.log(`\n📂 Procesando collectionGroup: ${nombreGrupo}`);
  const groupRef = db.collectionGroup(nombreGrupo);

  let escaneados = 0;
  let actualizados = 0;
  let omitidos = 0;
  let errores = 0;
  let cursor = null;
  let batch = db.batch();
  let batchOps = 0;

  for (;;) {
    let consulta = groupRef.limit(PAGE_SIZE);
    if (cursor) consulta = consulta.startAfter(cursor);

    const pagina = await consulta.get();
    if (pagina.empty) break;
    cursor = pagina.docs[pagina.docs.length - 1];

    for (const doc of pagina.docs) {
      escaneados++;
      if (limiteGlobal && escaneados > limiteGlobal) break;

      const data = doc.data();

      const tieneOculto = 'oculto' in data;
      const hiddenTrue = data.hidden === true;

      if (tieneOculto) {
        omitidos++;
        continue;
      }

      const nuevoOculto = hiddenTrue ? true : false;

      // Contar documentos que requieren migración (tanto en simulacro como en escritura)
      actualizados++;

      if (aplicar) {
        try {
          batch.set(doc.ref, { oculto: nuevoOculto }, { merge: true });
          batchOps++;
        } catch (e) {
          errores++;
          console.error(`  ✗ Error en ${doc.id}: ${e.message}`);
        }
      }

      if (aplicar && batchOps >= BATCH_SIZE) {
        try {
          await batch.commit();
          batch = db.batch();
          batchOps = 0;
        } catch (e) {
          errores++;
          console.error(`  ✗ Error en commit batch: ${e.message}`);
          batch = db.batch();
          batchOps = 0;
        }
      }
    }

    if (limiteGlobal && escaneados >= limiteGlobal) break;
  }

  if (aplicar && batchOps > 0) {
    try {
      await batch.commit();
    } catch (e) {
      errores++;
      console.error(`  ✗ Error en commit final: ${e.message}`);
    }
  }

  console.log(`  Escaneados: ${escaneados} | Actualizados: ${actualizados} | Omitidos (ya tenían oculto): ${omitidos} | Errores: ${errores}`);
  return { escaneados, actualizados, omitidos, errores };
}

async function main() {
  const { projectId, aplicar, limit } = parseArgs();

  console.log('═══════════════════════════════════════════');
  console.log('  Migración campo "oculto" — AltarDiario');
  console.log('═══════════════════════════════════════════');
  console.log(`Proyecto: ${projectId}`);
  console.log(`Modo: ${aplicar ? 'ESCRITURA (--aplicar)' : 'SIMULACRO (solo cuenta)'}`);
  if (limit) console.log(`Límite: ${limit} docs por colección/grupo`);

  await cargarFirebaseAdmin();

  // Inicializar firebase-admin v12+ correctamente
  // admin.initializeApp devuelve la app, no se usa como variable global
  admin.initializeApp({
    projectId,
    credential: admin.credential.applicationDefault(),
  });

  // En v12+, se usa admin.firestore() (no getFirestore)
  const db = admin.firestore();

  const resumen = {
    totalEscaneados: 0,
    totalActualizados: 0,
    totalOmitidos: 0,
    totalErrores: 0,
    porColeccion: {},
  };

  // Procesar colecciones raíz
  for (const col of ROOT_COLLECTIONS) {
    const r = await procesarColeccionRaiz(db, col, aplicar, limit);
    resumen.totalEscaneados += r.escaneados;
    resumen.totalActualizados += r.actualizados;
    resumen.totalOmitidos += r.omitidos;
    resumen.totalErrores += r.errores;
    resumen.porColeccion[col] = r;
  }

  // Procesar collection groups
  for (const grupo of COLLECTION_GROUPS) {
    const r = await procesarCollectionGroup(db, grupo, aplicar, limit);
    resumen.totalEscaneados += r.escaneados;
    resumen.totalActualizados += r.actualizados;
    resumen.totalOmitidos += r.omitidos;
    resumen.totalErrores += r.errores;
    resumen.porColeccion[grupo] = r;
  }

  // Resumen final
  console.log('\n═══════════════════════════════════════════');
  console.log('  RESUMEN');
  console.log('═══════════════════════════════════════════');
  for (const [nombre, r] of Object.entries(resumen.porColeccion)) {
    console.log(`  ${nombre}: ${r.escaneados} escaneados, ${r.actualizados} actualizados, ${r.omitidos} omitidos, ${r.errores} errores`);
  }
  console.log('  ────────────────────────────────────────');
  console.log(`  TOTAL: ${resumen.totalEscaneados} escaneados, ${resumen.totalActualizados} actualizados, ${resumen.totalOmitidos} omitidos, ${resumen.totalErrores} errores`);
  console.log(`  Modo: ${aplicar ? 'Migración APLICADA' : 'Simulacro (añade --aplicar para escribir)'}`);

  if (resumen.totalErrores > 0) {
    console.error('\n⚠ Hubo errores. Revisa el log.');
    process.exitCode = 1;
  }
}

main().catch((err) => {
  console.error('Error fatal:', err);
  process.exitCode = 1;
});