// Gamificación en servidor (ADR-0002).
//
// Hoy la app calcula XP e insignias en el cliente y las escribe en
// usuarios/{uid}. Eso es falsificable. Estas funciones son la fuente de
// verdad futura: reaccionan a eventos reales (documentos creados) y
// actualizan el perfil con transacciones.
//
// Plan de adopción:
//   1. Desplegar en paralelo al cliente (ambos escriben; servidor gana).
//   2. Cuando los números coincidan en producción, quitar la escritura del
//      cliente (gamification_service.dart) y bloquear los campos en reglas.

import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

export const XP = {
  reflexionPublicada: 15,
  comentario: 5,
  peticionOracion: 10,
  amenRecibido: 2,
  debateCreado: 10,
} as const;

/** Niveles por XP acumulado. Mantener sincronizado con gamification_service.dart */
export const NIVELES = [0, 50, 150, 300, 500, 800, 1200, 1700, 2300, 3000];

export function nivelPara(totalPuntos: number): number {
  let nivel = 1;
  for (let i = 0; i < NIVELES.length; i++) {
    if (totalPuntos >= NIVELES[i]) nivel = i + 1;
  }
  return nivel;
}

async function sumarXp(uid: string, puntos: number, motivo: string): Promise<void> {
  const db = getFirestore();
  const ref = db.collection('usuarios').doc(uid);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return;
    const actual = (snap.get('totalPuntos') as number | undefined) ?? 0;
    const nuevo = actual + puntos;
    tx.update(ref, {
      totalPuntos: nuevo,
      nivel: nivelPara(nuevo),
      xpLog: FieldValue.arrayUnion({ motivo, puntos, fecha: new Date().toISOString() }),
    });
  });
}

export const onReflexionCreada = onDocumentCreated('reflexiones/{id}', async (event) => {
  const uid = event.data?.get('userId') as string | undefined;
  if (uid) await sumarXp(uid, XP.reflexionPublicada, 'reflexion');
});

export const onComentarioCreado = onDocumentCreated(
  'reflexiones/{reflexionId}/comentarios/{id}',
  async (event) => {
    const uid = event.data?.get('userId') as string | undefined;
    if (uid) await sumarXp(uid, XP.comentario, 'comentario');
  },
);

export const onPeticionCreada = onDocumentCreated('peticiones_oracion/{id}', async (event) => {
  const uid = event.data?.get('userId') as string | undefined;
  if (uid) await sumarXp(uid, XP.peticionOracion, 'peticion');
});

export const onDebateCreado = onDocumentCreated('debates/{id}', async (event) => {
  const uid = event.data?.get('userId') as string | undefined;
  if (uid) await sumarXp(uid, XP.debateCreado, 'debate');
});
