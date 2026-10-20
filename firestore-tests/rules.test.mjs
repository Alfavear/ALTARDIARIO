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

test('notas y subrayados bíblicos son privados', async () => {
  await admin((db) => setDoc(doc(db, 'usuarios', ALICE, 'notes', 'n1'), { texto: 'secreto' }));
  await assertFails(getDoc(doc(as(BOB), 'usuarios', ALICE, 'notes', 'n1')));
  await assertSucceeds(getDoc(doc(as(ALICE), 'usuarios', ALICE, 'notes', 'n1')));
});

// ───────────────────────── Notificaciones ─────────────────────────

test('REGRESIÓN: nadie puede crear notificaciones suplantando a otro actor', async () => {
  const ok = { type: 'follow', title: 'Nuevo seguidor', body: 'Bob te sigue', data: {}, actorId: BOB, read: false, createdAt: new Date() };
  await assertSucceeds(setDoc(doc(as(BOB), 'usuarios', ALICE, 'notifications', 'n1'), ok));
  await assertFails(setDoc(doc(as(BOB), 'usuarios', ALICE, 'notifications', 'n2'), { ...ok, actorId: EVE }));
  await assertFails(setDoc(doc(as(BOB), 'usuarios', ALICE, 'notifications', 'n3'), { ...ok, read: true }));
  // Solo el receptor lee y marca como leída
  await assertFails(getDoc(doc(as(BOB), 'usuarios', ALICE, 'notifications', 'n1')));
  await assertSucceeds(updateDoc(doc(as(ALICE), 'usuarios', ALICE, 'notifications', 'n1'), { read: true }));
  await assertFails(updateDoc(doc(as(ALICE), 'usuarios', ALICE, 'notifications', 'n1'), { title: 'x' }));
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
  await assertSucceeds(setDoc(doc(as(ALICE), 'chats', 'ab'), { participantIds: [ALICE, BOB], lastUpdate: serverTimestamp() }));
  await assertSucceeds(addDoc(collection(as(ALICE), 'chats', 'ab', 'messages'), { senderId: ALICE, text: 'hey', timestamp: serverTimestamp() }));
  await assertFails(addDoc(collection(as(ALICE), 'chats', 'ab', 'messages'), { senderId: BOB, text: 'falso', timestamp: serverTimestamp() }));
  await assertFails(addDoc(collection(as(EVE), 'chats', 'ab', 'messages'), { senderId: EVE, text: 'intruso', timestamp: serverTimestamp() }));
  // No se puede cambiar la lista de participantes
  await assertFails(updateDoc(doc(as(ALICE), 'chats', 'ab'), { participantIds: [ALICE, EVE] }));
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
