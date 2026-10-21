// Moderación mínima exigida por las tiendas para apps con contenido de
// usuarios (App Store Review Guideline 1.2): reportar y bloquear.
//
// La app escribe en `reports/{id}` { reporterId, targetType, targetId, reason }.
// Esta función cuenta reportes y oculta automáticamente contenido con >= 3
// reportes de usuarios distintos, marcándolo `hidden: true` para que el
// cliente lo filtre. Un humano revisa en la consola (`reports` con estado).

import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { getFirestore } from 'firebase-admin/firestore';

const UMBRAL_OCULTAR = 3;
const COLECCION_POR_TIPO: Record<string, string> = {
  reflexion: 'reflexiones',
  peticion: 'peticiones_oracion',
  debate: 'debates',
};

export const onReporteCreado = onDocumentCreated('reports/{id}', async (event) => {
  const data = event.data?.data();
  if (!data) return;
  const { targetType, targetId } = data as { targetType: string; targetId: string };
  const col = COLECCION_POR_TIPO[targetType];
  if (!col) return;

  const db = getFirestore();
  const reportes = await db
    .collection('reports')
    .where('targetType', '==', targetType)
    .where('targetId', '==', targetId)
    .get();
  const reporters = new Set(reportes.docs.map((d) => d.get('reporterId')));

  if (reporters.size >= UMBRAL_OCULTAR) {
    await db.collection(col).doc(targetId).set(
      { hidden: true, hiddenReason: 'reports', hiddenAt: new Date() },
      { merge: true },
    );
  }
});
