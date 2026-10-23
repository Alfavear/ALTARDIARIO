// Moderaci��n m��nima exigida por las tiendas para apps con contenido de
// usuarios (App Store Review Guideline 1.2): reportar y bloquear.
//
// La app escribe en `reports/{id}` { reporterId, targetType, targetId, reason }.
// Esta funci��n cuenta reportes y oculta automǭticamente contenido con >= 3
// reportes de usuarios distintos, marcǭndolo `hidden: true` para que el
// cliente lo filtre. Un humano revisa en la consola (`reports` con estado).
//
// targetType y su ruta:
//   reflexion   -> reflexiones/{id}
//   peticion    -> peticiones_oracion/{id}
//   debate      -> debates/{id}
//   usuario     -> usuarios/{id}
//   comentario  -> reflexiones/{reflexionId}/comentarios/{id}
//     (se resuelve con una consulta de grupo de colecciones por documentId,
//      porque el reporte solo guarda comment.id)

import type { Firestore } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { FieldPath, getFirestore } from 'firebase-admin/firestore';

const UMBRAL_OCULTAR = 3;

// Colecciones con documento directo (targetId es el id del documento).
const COLECCION_DIRECTA: Record<string, string> = {
  reflexion: 'reflexiones',
  peticion: 'peticiones_oracion',
  debate: 'debates',
  usuario: 'usuarios',
};

async function existeDocumento(
  db: Firestore,
  ruta: string,
): Promise<boolean> {
  const snap = await db.doc(ruta).get();
  return snap.exists;
}

// Logica de moderaci��n separada del binding de Firebase para poder probarla sin emulador.
// Tipo para la función de resolución de ruta de comentario (inyectable para tests).
export type ResolvedorComentario = (
  db: Firestore,
  commentId: string,
) => Promise<string | null>;

async function rutaDeComentarioDefecto(
  db: Firestore,
  commentId: string,
): Promise<string | null> {
  const snap = await db
    .collectionGroup('comentarios')
    .where(FieldPath.documentId(), '==', commentId)
    .limit(1)
    .get();
  if (snap.empty) return null;
  return snap.docs[0].ref.path;
}

export async function procesarReporte(
  db: Firestore,
  data: any,
  resolver: ResolvedorComentario = rutaDeComentarioDefecto,
): Promise<void> {
  const { targetType, targetId } = data as {
    targetType: string;
    targetId: string;
  };
  if (!targetType || !targetId) return;

  let ruta: string | null = null;

  if (targetType === 'comentario') {
    ruta = await resolver(db, targetId);
  } else {
    const col = COLECCION_DIRECTA[targetType];
    if (!col) return; // tipo desconocido: ignora, no lanza
    ruta = `${col}/${targetId}`;
    if (!(await existeDocumento(db, ruta))) return; // target inexistente: no lanza
  }

  if (!ruta) return; // comentario inexistente: no lanza

  const reportes = await db
    .collection('reports')
    .where('targetType', '==', targetType)
    .where('targetId', '==', targetId)
    .get();
  const reporters = new Set(reportes.docs.map((d) => d.get('reporterId')));

  if (reporters.size >= UMBRAL_OCULTAR) {
    await db.doc(ruta).set(
      { hidden: true, hiddenReason: 'reports', hiddenAt: new Date() },
      { merge: true },
    );
  }
}

export const onReporteCreado = onDocumentCreated('reports/{id}', async (event) => {
  const data = event.data?.data();
  if (!data) return;
  await procesarReporte(getFirestore(), data);
});
