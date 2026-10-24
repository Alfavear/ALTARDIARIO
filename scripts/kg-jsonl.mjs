// Núcleo del grafo de conocimiento versionado.
//
// El servidor `@modelcontextprotocol/server-memory` persiste JSONL, no un JSON
// único: un registro por línea, con `type: "entity"` o `type: "relation"`.
// Este módulo habla ese formato y nada más. Es puro: no toca red ni disco, para
// poder testearlo sin emuladores ni LLM.

export const ALLOWED_ENTITY_TYPES = new Set([
  'feature',
  'service',
  'model',
  'provider',
  'screen',
  'collection',
  'endpoint',
  'cloud-function',
  'security-rule',
  'adr',
  'config',
]);

export const ALLOWED_RELATION_TYPES = new Set([
  'calls',
  'reads_from',
  'writes_to',
  'renders',
  'guarded_by',
  'depends_on',
]);

/**
 * Convierte el texto JSONL en { entities, relations }.
 * Lanza si una línea no es JSON o si el registro no tiene un `type` conocido:
 * preferimos fallar a sobrescribir el grafo con datos a medias.
 */
export function parseGraph(text) {
  const entities = [];
  const relations = [];

  if (typeof text !== 'string') {
    return { entities, relations };
  }

  // Un BOM al inicio (Windows: Notepad, Set-Content) rompe JSON.parse de la
  // primera línea. No es dato: se descarta.
  const clean = text.charCodeAt(0) === 0xfeff ? text.slice(1) : text;
  if (clean.trim() === '') {
    return { entities, relations };
  }

  const lines = clean.split(/\r?\n/);

  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i].trim();
    if (line === '') continue;

    let record;
    try {
      record = JSON.parse(line);
    } catch (error) {
      throw new Error(`Grafo: linea ${i + 1} no es JSON valido: ${error.message}`);
    }

    if (record.type === 'entity') {
      entities.push({
        name: record.name,
        entityType: record.entityType,
        observations: Array.isArray(record.observations) ? record.observations : [],
      });
      continue;
    }

    if (record.type === 'relation') {
      relations.push({
        from: record.from,
        to: record.to,
        relationType: record.relationType,
      });
      continue;
    }

    throw new Error(`Grafo: linea ${i + 1} tiene un type desconocido: ${JSON.stringify(record.type)}`);
  }

  return { entities, relations };
}

/**
 * Serializa el grafo a JSONL con orden estable (entidades por nombre,
 * relaciones por extremos y tipo). Sin orden estable, cada sync produce un
 * diff enorme aunque no haya cambios reales.
 */
export function serializeGraph(graph) {
  const entities = [...graph.entities].sort((a, b) =>
    String(a.name).toLowerCase().localeCompare(String(b.name).toLowerCase()),
  );

  const relations = [...graph.relations].sort((a, b) => {
    const keyA = `${a.from}|${a.to}|${a.relationType}`.toLowerCase();
    const keyB = `${b.from}|${b.to}|${b.relationType}`.toLowerCase();
    return keyA.localeCompare(keyB);
  });

  const lines = [];

  for (const entity of entities) {
    lines.push(
      JSON.stringify({
        type: 'entity',
        name: entity.name,
        entityType: entity.entityType,
        observations: entity.observations,
      }),
    );
  }

  for (const relation of relations) {
    lines.push(
      JSON.stringify({
        type: 'relation',
        from: relation.from,
        to: relation.to,
        relationType: relation.relationType,
      }),
    );
  }

  return lines.length === 0 ? '' : `${lines.join('\n')}\n`;
}

function requireText(value, field) {
  if (typeof value !== 'string' || value.trim() === '') {
    throw new Error(`Actualizacion invalida: falta "${field}" o no es texto.`);
  }
  return value.trim();
}

/**
 * Valida la salida del LLM antes de tocar el grafo. Devuelve una versión
 * normalizada o lanza. Nunca confiamos en la forma del JSON del modelo.
 */
export function validateUpdates(raw) {
  const input = raw && typeof raw === 'object' ? raw : {};
  const entities = [];
  const relations = [];
  const deletedEntities = [];

  const rawEntities = Array.isArray(input.entities) ? input.entities : [];
  for (const candidate of rawEntities) {
    const name = requireText(candidate?.name, 'name');
    const entityType = requireText(candidate?.entityType, 'entityType');
    if (!ALLOWED_ENTITY_TYPES.has(entityType)) {
      throw new Error(`Actualizacion invalida: entityType no permitido "${entityType}".`);
    }
    const observations = Array.isArray(candidate?.observations)
      ? candidate.observations.filter((o) => typeof o === 'string' && o.trim() !== '')
      : [];
    entities.push({ name, entityType, observations });
  }

  const rawRelations = Array.isArray(input.relations) ? input.relations : [];
  for (const candidate of rawRelations) {
    const from = requireText(candidate?.from, 'from');
    const to = requireText(candidate?.to, 'to');
    const relationType = requireText(candidate?.relationType, 'relationType');
    if (!ALLOWED_RELATION_TYPES.has(relationType)) {
      throw new Error(`Actualizacion invalida: relationType no permitido "${relationType}".`);
    }
    relations.push({ from, to, relationType });
  }

  // El prompt pide `candidateDeletions`; aceptamos también `deletedEntities`
  // para no acoplar el contrato a una sola redacción del modelo.
  const rawDeletions = Array.isArray(input.candidateDeletions)
    ? input.candidateDeletions
    : Array.isArray(input.deletedEntities)
      ? input.deletedEntities
      : [];
  for (const candidate of rawDeletions) {
    if (typeof candidate === 'string' && candidate.trim() !== '') {
      deletedEntities.push(candidate.trim());
    }
  }

  return { entities, relations, deletedEntities };
}

/** Quita relaciones cuyo `from` o `to` ya no existe. Devuelve también lo podado. */
export function pruneOrphanRelations(relations, entities) {
  const validNames = new Set(entities.map((entity) => String(entity.name).toLowerCase()));
  const kept = [];
  const removed = [];

  for (const relation of relations) {
    const fromExists = validNames.has(String(relation.from ?? '').toLowerCase());
    const toExists = validNames.has(String(relation.to ?? '').toLowerCase());
    if (fromExists && toExists) {
      kept.push(relation);
    } else {
      removed.push(relation);
    }
  }

  return { relations: kept, removed };
}

/**
 * Mezcla la extracción del LLM con el grafo existente.
 *
 * - Las observaciones se UNEN: nunca se reemplazan (el modelo solo ve un diff,
 *   no todo el histórico).
 * - Los borrados solo se aplican si el llamador los confirmó contra el código.
 */
export function mergeUpdates(graph, rawUpdates, { confirmedDeletions = new Set() } = {}) {
  const updates = validateUpdates(rawUpdates);
  const entities = graph.entities.map((entity) => ({
    name: entity.name,
    entityType: entity.entityType,
    observations: [...entity.observations],
  }));
  const relations = graph.relations.map((relation) => ({ ...relation }));

  const stats = {
    entitiesAdded: 0,
    entitiesUpdated: 0,
    entitiesDeleted: 0,
    relationsAdded: 0,
  };

  const confirmed = new Set([...confirmedDeletions].map((name) => String(name).toLowerCase()));
  const requested = new Set(updates.deletedEntities.map((name) => name.toLowerCase()));
  const toDelete = new Set([...requested].filter((name) => confirmed.has(name)));

  if (toDelete.size > 0) {
    for (let i = entities.length - 1; i >= 0; i -= 1) {
      if (toDelete.has(entities[i].name.toLowerCase())) {
        entities.splice(i, 1);
        stats.entitiesDeleted += 1;
      }
    }
  }

  const byName = new Map(entities.map((entity) => [entity.name.toLowerCase(), entity]));

  for (const incoming of updates.entities) {
    const key = incoming.name.toLowerCase();
    const existing = byName.get(key);

    if (!existing) {
      const created = { ...incoming, observations: [...incoming.observations] };
      entities.push(created);
      byName.set(key, created);
      stats.entitiesAdded += 1;
      continue;
    }

    existing.entityType = incoming.entityType;
    for (const observation of incoming.observations) {
      if (!existing.observations.includes(observation)) {
        existing.observations.push(observation);
      }
    }
    stats.entitiesUpdated += 1;
  }

  const relationKeys = new Set(
    relations.map((relation) =>
      `${relation.from}|${relation.to}|${relation.relationType}`.toLowerCase(),
    ),
  );

  for (const incoming of updates.relations) {
    const key = `${incoming.from}|${incoming.to}|${incoming.relationType}`.toLowerCase();
    if (relationKeys.has(key)) continue;
    relationKeys.add(key);
    relations.push(incoming);
    stats.relationsAdded += 1;
  }

  const pruned = pruneOrphanRelations(relations, entities);

  return {
    graph: { entities, relations: pruned.relations },
    stats: { ...stats, relationsPruned: pruned.removed.length },
    pruned: pruned.removed,
  };
}
