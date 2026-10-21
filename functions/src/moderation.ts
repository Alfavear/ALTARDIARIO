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

export type AccionModeracion = 'ignorar' | 'revisar_usuario' | 'ocultar_contenido';

/** Decide el tratamiento según el tipo de objetivo y el número de autores distintos. */
export function decidirAccionModeracion(
  targetType: string,
  reporterosDistintos: number,
): AccionModeracion {
  if (reporterosDistintos < UMBRAL_OCULTAR) return 'ignorar';
  if (targetType === 'usuario') return 'revisar_usuario';
  return COLECCION_POR_TIPO[targetType] ? 'ocultar_contenido' : 'ignorar';
}

export const onReporteCreado = onDocumentCreated('reports/{id}', async (event) => {
  const data = event.data?.data();
  if (!data) return;
  const { targetType, targetId } = data as { targetType: string; targetId: string };
  const col = COLECCION_POR_TIPO[targetType];
  if (!col && targetType !== 'usuario') return;

  const db = getFirestore();
  const reportes = await db
    .collection('reports')
    .where('targetType', '==', targetType)
    .where('targetId', '==', targetId)
    .get();
  const reporters = new Set(reportes.docs.map((d) => d.get('reporterId')));

  const accion = decidirAccionModeracion(targetType, reporters.size);
  if (accion === 'revisar_usuario') {
    // No se oculta el perfil automáticamente: un umbral de reportes solo
    // marca el caso para revisión humana y evita sanciones automáticas abusables.
    await db.collection('usuarios').doc(targetId).set(
      {
        moderationStatus: 'review_required',
        moderationReportCount: reporters.size,
        moderationReportedAt: new Date(),
      },
      { merge: true },
    );
    return;
  }

  if (accion === 'ocultar_contenido' && col) {
    await db.collection(col).doc(targetId).set(
      { hidden: true, hiddenReason: 'reports', hiddenAt: new Date() },
      { merge: true },
    );
  }
});
