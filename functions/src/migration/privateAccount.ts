// Migración de los campos privados del perfil público a su subdocumento
// privado: `usuarios/{uid}` -> `usuarios/{uid}/private/account`.
//
// La app escribe `email` y `fcmToken` en el documento público del perfil.
// Las reglas definitivas los prohíben ahí, así que antes hay que moverlos.
// Esta lógica es pura (sin firebase-admin) para poder testearla sin emulador.

/** Campos del perfil público que son datos privados del usuario. */
export const CAMPOS_PRIVADOS = ['email', 'fcmToken'] as const;

export type CampoPrivado = (typeof CAMPOS_PRIVADOS)[number];

export type Documento = Record<string, unknown>;

export interface PlanMigracion {
  /** uid del usuario propietario del perfil. */
  uid: string;
  /** Campos a escribir en `usuarios/{uid}/private/account`. */
  copiar: Partial<Record<CampoPrivado, unknown>>;
  /** Campos a borrar del documento público. */
  borrar: CampoPrivado[];
  /** Campos que ya existían en el documento privado: no se sobrescriben. */
  omitidos: CampoPrivado[];
}

function valorPresente(valor: unknown): boolean {
  if (valor === undefined || valor === null) return false;
  if (typeof valor === 'string') return valor.trim() !== '';
  return true;
}

/**
 * Calcula qué hay que mover de un perfil público a su documento privado.
 *
 * Reglas:
 * - Si el documento público no tiene campos privados, no hay nada que hacer:
 *   la migración es idempotente y se puede repetir sin riesgo.
 * - Si el documento privado ya tiene el campo, **gana el privado**: no se
 *   sobrescribe. El token de FCM más reciente puede estar en cualquiera de
 *   los dos sitios y sobrescribirlo dejaría al usuario sin notificaciones.
 * - El campo público se borra en cuanto se ha copiado o ya existía en privado.
 */
export function planMigracion(
  uid: string,
  publico: Documento,
  privado: Documento = {},
): PlanMigracion | null {
  const copiar: Partial<Record<CampoPrivado, unknown>> = {};
  const borrar: CampoPrivado[] = [];
  const omitidos: CampoPrivado[] = [];

  for (const campo of CAMPOS_PRIVADOS) {
    const valor = publico[campo];
    if (!valorPresente(valor)) continue;
    if (valorPresente(privado[campo])) {
      omitidos.push(campo);
    } else {
      copiar[campo] = valor;
    }
    borrar.push(campo);
  }

  if (borrar.length === 0) return null;
  return { uid, copiar, borrar, omitidos };
}
