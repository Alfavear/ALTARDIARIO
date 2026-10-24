import test from 'node:test';
import assert from 'node:assert/strict';

import {
  parseGraph,
  serializeGraph,
  mergeUpdates,
  pruneOrphanRelations,
  validateUpdates,
} from '../kg-jsonl.mjs';

const LINEA_ENTIDAD =
  '{"type":"entity","name":"Reflexion","entityType":"model","observations":["id, autorId, texto"]}';
const LINEA_RELACION =
  '{"type":"relation","from":"FeedPage","to":"Reflexion","relationType":"reads_from"}';

test('parseGraph lee JSONL con entidades y relaciones', () => {
  const grafo = parseGraph(`${LINEA_ENTIDAD}\n${LINEA_RELACION}\n`);

  assert.equal(grafo.entities.length, 1);
  assert.equal(grafo.entities[0].name, 'Reflexion');
  assert.deepEqual(grafo.entities[0].observations, ['id, autorId, texto']);
  assert.equal(grafo.relations.length, 1);
  assert.equal(grafo.relations[0].relationType, 'reads_from');
});

test('parseGraph ignora lineas vacias y acepta archivo vacio', () => {
  assert.deepEqual(parseGraph(''), { entities: [], relations: [] });
  assert.deepEqual(parseGraph('\n\n  \n'), { entities: [], relations: [] });
});

test('parseGraph tolera un BOM al inicio (Windows)', () => {
  const grafo = parseGraph(`\uFEFF${LINEA_ENTIDAD}`);
  assert.equal(grafo.entities.length, 1);
  assert.equal(grafo.entities[0].name, 'Reflexion');
});

test('parseGraph falla con numero de linea si el archivo no es JSONL', () => {
  const jsonUnico = '{"entities":[],"relations":[]}';

  assert.throws(
    () => parseGraph(`${LINEA_ENTIDAD}\n${jsonUnico}\n`),
    (error) => {
      assert.match(error.message, /linea 2/i);
      return true;
    },
  );
});

test('parseGraph rechaza registros con type desconocido', () => {
  assert.throws(
    () => parseGraph('{"type":"meta","version":2}'),
    /type desconocido/i,
  );
});

test('serializeGraph es determinista y hace round-trip', () => {
  const grafo = {
    entities: [
      { name: 'Zeta', entityType: 'service', observations: ['b'] },
      { name: 'alfa', entityType: 'model', observations: ['a'] },
    ],
    relations: [
      { from: 'Zeta', to: 'alfa', relationType: 'calls' },
      { from: 'alfa', to: 'Zeta', relationType: 'reads_from' },
    ],
  };

  const primera = serializeGraph(grafo);
  const segunda = serializeGraph(grafo);
  assert.equal(primera, segunda);

  // Entidades ordenadas por nombre sin distinguir mayusculas.
  const nombres = parseGraph(primera).entities.map((e) => e.name);
  assert.deepEqual(nombres, ['alfa', 'Zeta']);

  assert.deepEqual(parseGraph(primera), parseGraph(serializeGraph(parseGraph(primera))));
});

test('serializeGraph termina en salto de linea y usa LF', () => {
  const texto = serializeGraph({ entities: [], relations: [] });
  assert.equal(texto, '');
  assert.ok(!texto.includes('\r'));

  const conDatos = serializeGraph(parseGraph(LINEA_ENTIDAD));
  assert.ok(conDatos.endsWith('\n'));
  assert.ok(!conDatos.includes('\r'));
});

test('mergeUpdates une observaciones en vez de reemplazarlas', () => {
  const grafo = parseGraph(LINEA_ENTIDAD);
  const { graph, stats } = mergeUpdates(grafo, {
    entities: [
      {
        name: 'reflexion',
        entityType: 'model',
        // "id, autorId, texto" ya existe: debe deduplicarse, no duplicarse.
        observations: ['id, autorId, texto', 'creadoEn'],
      },
    ],
  });

  assert.equal(graph.entities.length, 1);
  assert.deepEqual(graph.entities[0].observations, ['id, autorId, texto', 'creadoEn']);
  assert.equal(stats.entitiesUpdated, 1);
  assert.equal(stats.entitiesAdded, 0);
});

test('mergeUpdates añade entidades nuevas y no duplica relaciones', () => {
  const grafo = parseGraph(`${LINEA_ENTIDAD}\n${LINEA_RELACION}`);
  const { graph, stats } = mergeUpdates(grafo, {
    entities: [{ name: 'FeedPage', entityType: 'screen', observations: ['lista'] }],
    relations: [
      { from: 'FeedPage', to: 'Reflexion', relationType: 'reads_from' },
      { from: 'FeedPage', to: 'Reflexion', relationType: 'writes_to' },
    ],
  });

  assert.equal(graph.entities.length, 2);
  assert.equal(graph.relations.length, 2);
  assert.equal(stats.entitiesAdded, 1);
  assert.equal(stats.relationsAdded, 1);
});

test('mergeUpdates solo borra lo confirmado por el codigo', () => {
  const grafo = parseGraph(`${LINEA_ENTIDAD}\n${LINEA_RELACION}`);

  const sinConfirmar = mergeUpdates(grafo, { deletedEntities: ['Reflexion'] });
  assert.equal(sinConfirmar.graph.entities.length, 1);
  assert.equal(sinConfirmar.stats.entitiesDeleted, 0);

  const confirmado = mergeUpdates(grafo, { deletedEntities: ['Reflexion'] }, {
    confirmedDeletions: new Set(['reflexion']),
  });
  assert.equal(confirmado.graph.entities.length, 0);
  assert.equal(confirmado.stats.entitiesDeleted, 1);
  // La arista que apuntaba al nodo borrado se poda.
  assert.equal(confirmado.graph.relations.length, 0);
});

test('pruneOrphanRelations elimina aristas con extremos inexistentes', () => {
  const grafo = parseGraph(`${LINEA_ENTIDAD}\n${LINEA_RELACION}`);
  grafo.entities = grafo.entities.filter((e) => e.name !== 'Reflexion');

  const { relations, removed } = pruneOrphanRelations(grafo.relations, grafo.entities);

  assert.equal(relations.length, 0);
  assert.equal(removed.length, 1);
  assert.equal(removed[0].to, 'Reflexion');
});

test('pruneOrphanRelations compara sin distinguir mayusculas', () => {
  const relaciones = [{ from: 'feedpage', to: 'REFLEXION', relationType: 'reads_from' }];
  const entidades = [{ name: 'FeedPage' }, { name: 'Reflexion' }];

  assert.equal(pruneOrphanRelations(relaciones, entidades).removed.length, 0);
});

test('validateUpdates rechaza tipos de entidad no permitidos', () => {
  assert.throws(
    () => validateUpdates({ entities: [{ name: 'X', entityType: 'inventado', observations: [] }] }),
    /entityType no permitido/i,
  );
});

test('validateUpdates rechaza relaciones sin extremos', () => {
  assert.throws(
    () => validateUpdates({ relations: [{ to: 'X', relationType: 'calls' }] }),
    /from/i,
  );
});

test('validateUpdates acepta candidateDeletions (nombre que usa el prompt)', () => {
  const updates = validateUpdates({ candidateDeletions: ['Vieja'] });
  assert.deepEqual(updates.deletedEntities, ['Vieja']);
});

test('validateUpdates acepta la salida vacia del modelo', () => {
  assert.deepEqual(validateUpdates({}), {
    entities: [],
    relations: [],
    deletedEntities: [],
  });
});
