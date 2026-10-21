// Tests de reglas de seguridad de Firestore — AltarDiario
// Ejecutar: scripts/rules_test.sh  (o `npm test` dentro de firestore-tests/)
//
// Cada test documenta un invariante de seguridad. Si cambias firestore.rules
// y un test falla, o la regla está mal o el test necesita actualizarse: nunca
// borres un test para "hacer pasar" el pipeline.

import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, setDoc, updateDoc, deleteDoc, getDoc, addDoc, collection,
  arrayUnion, arrayRemove, increment, deleteField, serverTimestamp,
  writeBatch,
} from 'firebase/firestore';

const PROJECT = 'altardiario-ec25f';
const ALICE = 'alice-uid';
const BOB = 'bob-uid';
const EVE = 'eve-uid';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: PROJECT,
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
      host: process.env.FIRESTORE_EMULATOR_HOST?.split(':')[0] ?? '127.0.0.1',
      port: Number(process.env.FIRESTORE_EMULATOR_HOST?.split(':')[1] ?? 8080),
    },
  });
});

after(async () => { await env.cleanup(); });
beforeEach(async () => { await env.clearFirestore(); });

const as = (uid) => env.authenticatedContext(uid).firestore();
const anon = () => env.unauthenticatedContext().firestore();
const admin = (fn) => env.withSecurityRulesDisabled((ctx) => fn(ctx.firestore()));

const seedReflexion = (id = 'r1', userId = ALICE) =>
  admin((db) => setDoc(doc(db, 'reflexiones', id), {
    userId, userName: 'Alice', texto: 'Dios es fiel', fecha: new Date(),
    pasajeDia: 'Salmo 23', likes: 0, likedBy: [], commentCount: 0, reactions: {}, tags: [],
  }));

// ───────────────────────── Reflexiones ─────────────────────────

test('cualquiera (incluso anónimo) puede leer el feed', async () => {
  await seedReflexion();
  await assertSucceeds(getDoc(doc(anon(), 'reflexiones', 'r1')));
});

test('solo el autor puede crear una reflexión con su propio userId', async () => {
  const data = { userId: ALICE, userName: 'Alice', texto: 'Hola', fecha: new Date(), pasajeDia: 'Gn 1' };
  await assertSucceeds(setDoc(doc(as(ALICE), 'reflexiones', 'x'), data));
  await assertFails(setDoc(doc(as(BOB), 'reflexiones', 'y'), data)); // suplantación
  await assertFails(setDoc(doc(anon(), 'reflexiones', 'z'), data));
});

test('una reflexión no puede estar vacía ni superar 5000 caracteres', async () => {
  const base = { userId: ALICE, userName: 'Alice', fecha: new Date(), pasajeDia: 'Gn 1' };
  await assertFails(setDoc(doc(as(ALICE), 'reflexiones', 'a'), { ...base, texto: '' }));
  await assertFails(setDoc(doc(as(ALICE), 'reflexiones', 'b'), { ...base, texto: 'x'.repeat(5001) }));
});

test('REGRESIÓN: un usuario NO puede editar el texto de la reflexión de otro', async () => {
  await seedReflexion();
  await assertFails(updateDoc(doc(as(BOB), 'reflexiones', 'r1'), { texto: 'hackeado' }));
  await assertSucceeds(updateDoc(doc(as(ALICE), 'reflexiones', 'r1'), { texto: 'editado por mí' }));
});

test('el autor no puede reasignar la autoría de su reflexión', async () => {
  await seedReflexion();
  await assertFails(updateDoc(doc(as(ALICE), 'reflexiones', 'r1'), { userId: BOB }));
});

test('cualquier usuario puede dar y quitar like (solo con su propio uid)', async () => {
  await seedReflexion();
  await assertSucceeds(updateDoc(doc(as(BOB), 'reflexiones', 'r1'), {
    likes: increment(1), likedBy: arrayUnion(BOB),
  }));
  await assertSucceeds(updateDoc(doc(as(BOB), 'reflexiones', 'r1'), {
    likes: increment(-1), likedBy: arrayRemove(BOB),
  }));
  // Bob intenta meter el uid de Eve
  await assertFails(updateDoc(doc(as(BOB), 'reflexiones', 'r1'), {
    likes: increment(1), likedBy: arrayUnion(EVE),
  }));
  // Bob intenta inflar el contador
  await assertFails(updateDoc(doc(as(BOB), 'reflexiones', 'r1'), {
    likes: increment(50), likedBy: arrayUnion(BOB),
  }));
});

test('reacciones: solo se puede escribir la clave del propio uid', async () => {
  await seedReflexion();
  await assertSucceeds(updateDoc(doc(as(BOB), 'reflexiones', 'r1'), { [`reactions.${BOB}`]: '🙏' }));
  await assertSucceeds(updateDoc(doc(as(BOB), 'reflexiones', 'r1'), { [`reactions.${BOB}`]: deleteField() }));
  await assertFails(updateDoc(doc(as(BOB), 'reflexiones', 'r1'), { [`reactions.${ALICE}`]: '🔥' }));
});

test('commentCount solo puede variar ±1', async () => {
  await seedReflexion();
  await assertSucceeds(updateDoc(doc(as(BOB), 'reflexiones', 'r1'), { commentCount: increment(1) }));
  await assertFails(updateDoc(doc(as(BOB), 'reflexiones', 'r1'), { commentCount: increment(10) }));
});

test('solo el autor puede borrar su reflexión', async () => {
  await seedReflexion();
  await assertFails(deleteDoc(doc(as(BOB), 'reflexiones', 'r1')));
  await assertSucceeds(deleteDoc(doc(as(ALICE), 'reflexiones', 'r1')));
});

test('comentarios: crear con uid propio; nadie edita el de otro', async () => {
  await seedReflexion();
  const c = doc(as(BOB), 'reflexiones', 'r1', 'comentarios', 'c1');
  await assertSucceeds(setDoc(c, { userId: BOB, userName: 'Bob', texto: 'Amén', fecha: new Date(), likes: 0, likedBy: [] }));
  await assertFails(updateDoc(doc(as(ALICE), 'reflexiones', 'r1', 'comentarios', 'c1'), { texto: 'cambiado' }));
  await assertSucceeds(updateDoc(doc(as(ALICE), 'reflexiones', 'r1', 'comentarios', 'c1'), {
    likes: increment(1), likedBy: arrayUnion(ALICE),
  }));
});

// ───────────────────────── Peticiones ─────────────────────────

test('petición: "Amén" (+1) permitido a cualquiera, edición solo al dueño', async () => {
  await admin((db) => setDoc(doc(db, 'peticiones_oracion', 'p1'), {
    userId: ALICE, userName: 'Alice', motivo: 'Salud', fecha: new Date(), oracionesCount: 0,
  }));
  await assertSucceeds(updateDoc(doc(as(BOB), 'peticiones_oracion', 'p1'), { oracionesCount: increment(1) }));
  await assertFails(updateDoc(doc(as(BOB), 'peticiones_oracion', 'p1'), { oracionesCount: increment(100) }));
  await assertFails(updateDoc(doc(as(BOB), 'peticiones_oracion', 'p1'), { motivo: 'otro' }));
  await assertSucceeds(updateDoc(doc(as(ALICE), 'peticiones_oracion', 'p1'), { motivo: 'Salud de mi madre' }));
});

test('petición y feedback: se crean firmados con el uid propio', async () => {
  const peticion = {
    userId: ALICE, userName: 'Alice', motivo: 'Salud', fecha: new Date(),
    oracionesCount: 0,
  };
  await assertSucceeds(addDoc(collection(as(ALICE), 'peticiones_oracion'), peticion));
  await assertFails(addDoc(collection(as(BOB), 'peticiones_oracion'), { ...peticion, userId: ALICE }));

  const feedback = {
    userId: BOB, userName: 'Bob', mensaje: 'Muy buena app', calificacion: 5,
    fecha: serverTimestamp(), appVersion: '1.0.0',
  };
  const creado = await assertSucceeds(addDoc(collection(as(BOB), 'feedback'), feedback));
  await assertFails(addDoc(collection(as(BOB), 'feedback'), { ...feedback, userId: ALICE }));
  await assertSucceeds(getDoc(doc(as(BOB), 'feedback', creado.id)));
  await assertFails(getDoc(doc(as(ALICE), 'feedback', creado.id)));
});

// ───────────────────────── Debates ─────────────────────────

test('debates: votar con uid propio; no editar contenido ajeno', async () => {
  await admin((db) => setDoc(doc(db, 'debates', 'd1'), {
    userId: ALICE, userName: 'Alice', titulo: 'Fe y obras', contenido: '...', libroId: 'stg',
    libroNombre: 'Santiago', fecha: new Date(), upvotes: 0, votedBy: [], replyCount: 0,
  }));
  await assertSucceeds(updateDoc(doc(as(BOB), 'debates', 'd1'), { upvotes: increment(1), votedBy: arrayUnion(BOB) }));
  await assertFails(updateDoc(doc(as(BOB), 'debates', 'd1'), { contenido: 'troll' }));
  await assertFails(updateDoc(doc(as(BOB), 'debates', 'd1'), { upvotes: increment(1), votedBy: arrayUnion(EVE) }));
});

test('foro: crear debate y respuesta con el uid propio; replyCount +1 en debate ajeno', async () => {
  const debate = {
    titulo: 'Fe y obras', contenido: 'Santiago 2', userId: ALICE, userName: 'Alice',
    libroId: 'stg', libroNombre: 'Santiago', fecha: new Date().toISOString(),
    upvotes: 0, votedBy: [], replyCount: 0,
  };
  await assertSucceeds(setDoc(doc(as(ALICE), 'debates', 'd1'), debate));
  await assertFails(setDoc(doc(as(BOB), 'debates', 'd2'), { ...debate, userId: ALICE }));
  await assertFails(setDoc(doc(as(BOB), 'debates', 'd3'), { ...debate, userId: BOB, titulo: '' }));

  const respuesta = { userId: BOB, userName: 'Bob', contenido: 'Amén', fecha: new Date().toISOString() };
  await assertSucceeds(addDoc(collection(as(BOB), 'debates', 'd1', 'respuestas'), respuesta));
  await assertFails(addDoc(collection(as(BOB), 'debates', 'd1', 'respuestas'), { ...respuesta, userId: ALICE }));

  await assertSucceeds(updateDoc(doc(as(BOB), 'debates', 'd1'), { replyCount: increment(1) }));
  await assertFails(updateDoc(doc(as(BOB), 'debates', 'd1'), { replyCount: increment(5) }));
});

test('foro: votar una respuesta solo con el propio uid y ±1', async () => {
  await admin((db) => setDoc(doc(db, 'debates', 'd1', 'respuestas', 'r1'), {
    userId: ALICE, userName: 'Alice', contenido: '...', fecha: new Date().toISOString(),
    upvotes: 0, votedBy: [],
  }));
  await assertSucceeds(updateDoc(doc(as(BOB), 'debates', 'd1', 'respuestas', 'r1'), {
    upvotes: increment(1), votedBy: arrayUnion(BOB),
  }));
  await assertFails(updateDoc(doc(as(BOB), 'debates', 'd1', 'respuestas', 'r1'), {
    upvotes: increment(1), votedBy: arrayUnion(EVE),
  }));
  await assertFails(updateDoc(doc(as(BOB), 'debates', 'd1', 'respuestas', 'r1'), {
    upvotes: increment(5), votedBy: arrayUnion(BOB),
  }));
  await assertSucceeds(updateDoc(doc(as(BOB), 'debates', 'd1', 'respuestas', 'r1'), {
    upvotes: increment(-1), votedBy: arrayRemove(BOB),
  }));
});

// ───────────────────────── Usuarios ─────────────────────────

test('perfil: solo el dueño edita; otro solo puede seguir/dejar de seguir', async () => {
  await admin((db) => setDoc(doc(db, 'usuarios', ALICE), { nombre: 'Alice', seguidores: [], siguiendo: [] }));
  await assertSucceeds(updateDoc(doc(as(ALICE), 'usuarios', ALICE), { nombre: 'Alicia' }));
  await assertFails(updateDoc(doc(as(BOB), 'usuarios', ALICE), { nombre: 'Hack' }));
  await assertSucceeds(updateDoc(doc(as(BOB), 'usuarios', ALICE), { seguidores: arrayUnion(BOB) }));
  await assertSucceeds(updateDoc(doc(as(BOB), 'usuarios', ALICE), { seguidores: arrayRemove(BOB) }));
  await assertFails(updateDoc(doc(as(BOB), 'usuarios', ALICE), { seguidores: arrayUnion(EVE) }));
});

test('no se puede crear un perfil con el uid de otro', async () => {
  await assertFails(setDoc(doc(as(BOB), 'usuarios', ALICE), { nombre: 'Falsa Alice' }));
  await assertSucceeds(setDoc(doc(as(ALICE), 'usuarios', ALICE), { nombre: 'Alice' }));
});

test('perfil: set merge del propio doc (config, FCM, racha, XP) y deleteField del token', async () => {
  await admin((db) => setDoc(doc(db, 'usuarios', ALICE), {
    nombre: 'Alice', seguidores: [], siguiendo: [], fcmToken: 'token-viejo',
  }));
  await assertSucceeds(setDoc(doc(as(ALICE), 'usuarios', ALICE), { modoEnfoque: true }, { merge: true }));
  await assertSucceeds(setDoc(doc(as(ALICE), 'usuarios', ALICE), { fcmToken: deleteField() }, { merge: true }));
  await assertSucceeds(setDoc(doc(as(ALICE), 'usuarios', ALICE), {
    progresoLectura: [{ dia: 1, completado: true }], maxStreak: 3, lastSync: serverTimestamp(),
  }, { merge: true }));
  await assertSucceeds(setDoc(doc(as(ALICE), 'usuarios', ALICE), {
    badges: ['x'], totalPuntos: 10, nivel: 2,
  }, { merge: true }));
  await assertFails(setDoc(doc(as(BOB), 'usuarios', ALICE), { modoEnfoque: false }, { merge: true }));
});

test('seguir: set merge sobre el propio siguiendo y el seguidores del otro', async () => {
  await admin(async (db) => {
    await setDoc(doc(db, 'usuarios', ALICE), { nombre: 'Alice', seguidores: [], siguiendo: [] });
    await setDoc(doc(db, 'usuarios', BOB), { nombre: 'Bob', seguidores: [], siguiendo: [] });
  });
  await assertSucceeds(setDoc(doc(as(BOB), 'usuarios', BOB), { siguiendo: arrayUnion(ALICE) }, { merge: true }));
  await assertSucceeds(setDoc(doc(as(BOB), 'usuarios', ALICE), { seguidores: arrayUnion(BOB) }, { merge: true }));
  await assertSucceeds(setDoc(doc(as(BOB), 'usuarios', ALICE), { seguidores: arrayRemove(BOB) }, { merge: true }));
  await assertFails(setDoc(doc(as(BOB), 'usuarios', ALICE), { seguidores: arrayUnion(EVE) }, { merge: true }));
});

test('notas y subrayados bíblicos son privados', async () => {
  // Note.toMap() (lib/data/models/note.dart): payload real de la app.
  const nota = {
    id: 'n1', title: 'Secreto', content: 'secreto',
    createdAt: new Date().toISOString(), updatedAt: new Date().toISOString(),
  };
  await admin((db) => setDoc(doc(db, 'usuarios', ALICE, 'notes', 'n1'), nota));
  await assertFails(getDoc(doc(as(BOB), 'usuarios', ALICE, 'notes', 'n1')));
  await assertSucceeds(getDoc(doc(as(ALICE), 'usuarios', ALICE, 'notes', 'n1')));
});

test('bible_highlights, bible_notes y notes: escribir y borrar solo lo propio', async () => {
  // Shapes reales de los modelos Dart: estas reglas solo miran el uid, pero
  // el payload debe reflejar lo que la app escribe de verdad.
  const ahora = new Date().toISOString();
  const payloads = {
    // BibleHighlight.toFirestoreMap() — lib/data/models/bible_models.dart
    bible_highlights: {
      version: 'rvr1960', bookId: 19, chapter: 23, verseStart: 1, verseEnd: 3,
      colorHex: '#FFEB3B', createdAt: ahora, updatedAt: ahora,
    },
    // BibleNote.toFirestoreMap()
    bible_notes: {
      version: 'rvr1960', bookId: 19, bookName: 'Salmos', chapter: 23, verse: 1,
      body: 'El Señor es mi pastor', createdAt: ahora, updatedAt: ahora,
    },
    // Note.toMap() — lib/data/models/note.dart
    notes: {
      id: 'x1', title: 'Título', content: 'contenido',
      createdAt: ahora, updatedAt: ahora,
    },
  };
  for (const [sub, dato] of Object.entries(payloads)) {
    await assertSucceeds(setDoc(doc(as(ALICE), 'usuarios', ALICE, sub, 'x1'), dato, { merge: true }));
    await assertSucceeds(deleteDoc(doc(as(ALICE), 'usuarios', ALICE, sub, 'x1')));
    await assertFails(setDoc(doc(as(BOB), 'usuarios', ALICE, sub, 'x2'), dato, { merge: true }));
  }
  await admin((db) => setDoc(doc(db, 'usuarios', ALICE, 'notes', 'n2'), { ...payloads.notes, id: 'n2' }));
  await assertFails(deleteDoc(doc(as(BOB), 'usuarios', ALICE, 'notes', 'n2')));
  await assertSucceeds(deleteDoc(doc(as(ALICE), 'usuarios', ALICE, 'notes', 'n2')));
});

// ───────────────────────── Notificaciones ─────────────────────────

test('REGRESIÓN: nadie puede crear notificaciones suplantando a otro actor', async () => {
  const ok = { type: 'follow', title: 'Nuevo seguidor', body: 'Bob te sigue', data: {}, actorId: BOB, read: false, createdAt: new Date() };
  await assertSucceeds(setDoc(doc(as(BOB), 'usuarios', ALICE, 'notifications', 'n1'), ok));
  await assertFails(setDoc(doc(as(BOB), 'usuarios', ALICE, 'notifications', 'n2'), { ...ok, actorId: EVE }));
  await assertFails(setDoc(doc(as(BOB), 'usuarios', ALICE, 'notifications', 'n3'), { ...ok, read: true }));
  // Ni siquiera en su propio subárbol: la regla exige `uid() != userId`
  // (nadie se auto-notifica). El payload `ok` cumple el resto de cláusulas
  // (actorId == uid, claves requeridas, read == false), así que el único
  // motivo de rechazo posible es `uid() != userId`.
  await assertFails(setDoc(doc(as(BOB), 'usuarios', BOB, 'notifications', 'n4'), ok));
  // Solo el receptor lee y marca como leída
  await assertFails(getDoc(doc(as(BOB), 'usuarios', ALICE, 'notifications', 'n1')));
  await assertSucceeds(updateDoc(doc(as(ALICE), 'usuarios', ALICE, 'notifications', 'n1'), { read: true }));
  await assertFails(updateDoc(doc(as(ALICE), 'usuarios', ALICE, 'notifications', 'n1'), { title: 'x' }));
});

test('notificaciones: marcar todas como leídas en batch', async () => {
  const notificacion = {
    actorId: BOB, type: 'follow', title: 'Nuevo seguidor', body: 'Bob te sigue',
    data: {}, read: false, createdAt: new Date(),
  };
  await admin(async (db) => {
    await setDoc(doc(db, 'usuarios', ALICE, 'notifications', 'n1'), notificacion);
    await setDoc(doc(db, 'usuarios', ALICE, 'notifications', 'n2'), notificacion);
    await setDoc(doc(db, 'usuarios', BOB, 'notifications', 'n3'), notificacion);
  });

  // Un solo contexto por batch: writeBatch() y doc() deben compartir la misma
  // instancia de Firestore. Cada as(uid) crea una instancia distinta y el
  // batch rechaza referencias ajenas ("document reference is from a different
  // Firestore instance"), así que basta con pedir el contexto una vez.
  const aliceDb = as(ALICE);
  const batch = writeBatch(aliceDb);
  batch.update(doc(aliceDb, 'usuarios', ALICE, 'notifications', 'n1'), { read: true });
  batch.update(doc(aliceDb, 'usuarios', ALICE, 'notifications', 'n2'), { read: true });
  await assertSucceeds(batch.commit());

  // El commit tiene que haber escrito de verdad: un batch vacío también
  // pasaría assertSucceeds, así que se comprueba el efecto en los dos docs.
  const [leida1, leida2] = await Promise.all([
    getDoc(doc(aliceDb, 'usuarios', ALICE, 'notifications', 'n1')),
    getDoc(doc(aliceDb, 'usuarios', ALICE, 'notifications', 'n2')),
  ]);
  assert.equal(leida1.data().read, true);
  assert.equal(leida2.data().read, true);

  // Aunque el batch sea de Alice, no puede marcar como leída la notificación
  // de Bob: la regla de update exige uid() == userId del documento.
  const batchAjeno = writeBatch(aliceDb);
  batchAjeno.update(doc(aliceDb, 'usuarios', BOB, 'notifications', 'n3'), { read: true });
  await assertFails(batchAjeno.commit());
});

// ───────────────────────── Chats ─────────────────────────

test('REGRESIÓN: un tercero NO puede leer mensajes de un chat privado', async () => {
  await admin(async (db) => {
    await setDoc(doc(db, 'chats', 'ab'), { participantIds: [ALICE, BOB], lastMessage: 'hola' });
    await setDoc(doc(db, 'chats', 'ab', 'messages', 'm1'), { senderId: ALICE, text: 'hola', timestamp: new Date() });
  });
  await assertSucceeds(getDoc(doc(as(ALICE), 'chats', 'ab', 'messages', 'm1')));
  await assertSucceeds(getDoc(doc(as(BOB), 'chats', 'ab', 'messages', 'm1')));
  await assertFails(getDoc(doc(as(EVE), 'chats', 'ab', 'messages', 'm1')));
  await assertFails(getDoc(doc(as(EVE), 'chats', 'ab')));
});

test('chat: solo un participante puede crearlo y enviar mensajes firmados', async () => {
  await assertFails(setDoc(doc(as(EVE), 'chats', 'ab'), { participantIds: [ALICE, BOB] }));
  // El create exige exactamente 2 participantes. Alice sí está en la lista
  // (isParticipant pasa), así que el único motivo de rechazo es size() != 2.
  await assertFails(setDoc(doc(as(ALICE), 'chats', 'ac'), { participantIds: [ALICE, BOB, EVE] }));
  await assertFails(setDoc(doc(as(ALICE), 'chats', 'solo'), { participantIds: [ALICE] }));
  await assertSucceeds(setDoc(doc(as(ALICE), 'chats', 'ab'), { participantIds: [ALICE, BOB], lastUpdate: serverTimestamp() }));
  // Rama "solo metadatos": sin tocar participantIds también se puede actualizar.
  await assertSucceeds(updateDoc(doc(as(ALICE), 'chats', 'ab'), { lastMessage: 'hola' }));
  await assertSucceeds(addDoc(collection(as(ALICE), 'chats', 'ab', 'messages'), { senderId: ALICE, text: 'hey', timestamp: serverTimestamp() }));
  await assertFails(addDoc(collection(as(ALICE), 'chats', 'ab', 'messages'), { senderId: BOB, text: 'falso', timestamp: serverTimestamp() }));
  await assertFails(addDoc(collection(as(EVE), 'chats', 'ab', 'messages'), { senderId: EVE, text: 'intruso', timestamp: serverTimestamp() }));
  // No se puede cambiar la lista de participantes
  await assertFails(updateDoc(doc(as(ALICE), 'chats', 'ab'), { participantIds: [ALICE, EVE] }));
});

test('REGRESIÓN: el participante que no creó el chat puede responder (mismo conjunto, distinto orden)', async () => {
  await admin((db) => setDoc(doc(db, 'chats', 'ab'), {
    participantIds: [ALICE, BOB], lastMessage: 'hola', lastUpdate: new Date(),
  }));
  // Bob reenvía participantIds con su uid primero al enviar: mismo conjunto.
  await assertSucceeds(setDoc(doc(as(BOB), 'chats', 'ab'), {
    participantIds: [BOB, ALICE], lastMessage: 'respuesta', lastUpdate: new Date(),
  }, { merge: true }));
  await assertSucceeds(addDoc(collection(as(BOB), 'chats', 'ab', 'messages'), {
    senderId: BOB, text: 'respuesta', timestamp: serverTimestamp(),
  }));

  // Cambiar quiénes participan sigue prohibido.
  await assertFails(setDoc(doc(as(BOB), 'chats', 'ab'), {
    participantIds: [BOB, ALICE, EVE],
  }, { merge: true }));
  await assertFails(setDoc(doc(as(BOB), 'chats', 'ab'), {
    participantIds: [BOB, EVE],
  }, { merge: true }));
  await assertFails(setDoc(doc(as(BOB), 'chats', 'ab'), {
    participantIds: [BOB],
  }, { merge: true }));
  // Único caso donde sameMembers() da true y solo el size() de la lista salva:
  // [BOB, ALICE] -> [BOB, ALICE, ALICE] es el mismo set pero 3 elementos.
  await assertFails(setDoc(doc(as(BOB), 'chats', 'ab'), {
    participantIds: [BOB, ALICE, ALICE],
  }, { merge: true }));

  // Los mensajes siguen firmados con el uid propio.
  await assertFails(addDoc(collection(as(BOB), 'chats', 'ab', 'messages'), {
    senderId: ALICE, text: 'suplantación', timestamp: serverTimestamp(),
  }));
});

// ───────────────────────── Reportes ─────────────────────────

test('reportes: se crean con el uid propio y nadie los lee desde el cliente', async () => {
  const r = { reporterId: BOB, targetType: 'reflexion', targetId: 'r1', reason: 'spam', createdAt: new Date() };
  await assertSucceeds(setDoc(doc(as(BOB), 'reports', 'rep1'), r));
  await assertFails(setDoc(doc(as(BOB), 'reports', 'rep2'), { ...r, reporterId: ALICE }));
  await assertFails(setDoc(doc(as(BOB), 'reports', 'rep3'), { ...r, targetType: 'otro' }));
  await assertFails(getDoc(doc(as(BOB), 'reports', 'rep1')));
});

// ───────────────────────── Config / catch-all ─────────────────────────

test('config es solo lectura; colecciones desconocidas están cerradas', async () => {
  await admin((db) => setDoc(doc(db, 'config', 'app'), { minVersion: '1.0.0' }));
  await assertSucceeds(getDoc(doc(anon(), 'config', 'app')));
  await assertFails(setDoc(doc(as(ALICE), 'config', 'app'), { minVersion: '0' }));
  await assertFails(setDoc(doc(as(ALICE), 'colección_inventada', 'x'), { a: 1 }));
});
