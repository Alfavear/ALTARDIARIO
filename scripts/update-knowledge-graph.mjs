#!/usr/bin/env node
// Sincroniza el grafo de conocimiento versionado a partir del diff de un push.
//
// Contrato de seguridad:
//   - Si el grafo no parsea, ABORTA. Nunca lo resetea.
//   - Un borrado propuesto por el LLM solo se aplica si el identificador ya no
//     aparece en el código (ground truth), y solo para entidades que son
//     símbolos de código, no conceptos (colecciones, reglas, endpoints).
//   - El grafo resultante se ordena: si no hay cambios reales, no hay diff.

import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

import {
  ALLOWED_ENTITY_TYPES,
  ALLOWED_RELATION_TYPES,
  mergeUpdates,
  parseGraph,
  serializeGraph,
  validateUpdates,
} from './kg-jsonl.mjs';

const GRAPH_FILE = path.resolve(process.cwd(), process.env.GRAPH_FILE || '.opencode/knowledge-graph.jsonl');
const BASE_COMMIT = process.env.BASE_COMMIT || '';
const TARGET_COMMIT = process.env.TARGET_COMMIT || 'HEAD';
const MODEL = process.env.OPENAI_MODEL || 'gpt-4o-mini';
const BASE_URL = (process.env.OPENAI_BASE_URL || 'https://api.openai.com/v1').replace(/\/$/, '');

// Rutas cuyos cambios afectan a contratos. Debe coincidir con el filtro
// `paths` de .github/workflows/graph-sync.yml.
const CONTRACT_PATHS = [
  /^lib\/data\/models\//,
  /^lib\/data\/services\//,
  /^lib\/core\/services\//,
  /^lib\/features\/[^/]+\/(data|providers)\//,
  /^functions\/src\//,
  /^firestore\.rules$/,
];

// Una entidad solo puede borrarse si es un símbolo que vive en el código.
// `collection`, `security-rule`, `endpoint`, `config` y `feature` son
// conceptos: no aparecen literalmente y borrarlos por grep sería un falso
// positivo garantizado.
const DELETABLE_TYPES = new Set(['model', 'service', 'provider', 'screen', 'cloud-function', 'adr']);

const MAX_CHARS_PER_FILE = 12000;
const MAX_CHARS_TOTAL = 60000;

function git(args, options = {}) {
  return execFileSync('git', args, { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, ...options });
}

function listChangedContractFiles() {
  const raw = git(['diff', '--name-only', '--diff-filter=ACMR', `${BASE_COMMIT}..${TARGET_COMMIT}`]);
  return raw
    .split('\n')
    .map((file) => file.trim())
    .filter(Boolean)
    .filter((file) => CONTRACT_PATHS.some((pattern) => pattern.test(file)));
}

function buildDiff(files) {
  const chunks = [];
  let total = 0;
  let truncated = 0;

  for (const file of files) {
    let chunk;
    try {
      chunk = git(['diff', '--unified=3', `${BASE_COMMIT}..${TARGET_COMMIT}`, '--', file]);
    } catch {
      continue;
    }
    if (!chunk.trim()) continue;

    if (chunk.length > MAX_CHARS_PER_FILE) {
      chunk = `${chunk.slice(0, MAX_CHARS_PER_FILE)}\n... [diff truncado en ${file}]\n`;
      truncated += 1;
    }
    if (total + chunk.length > MAX_CHARS_TOTAL) {
      chunks.push('... [presupuesto total de diff agotado; hay archivos sin analizar]\n');
      truncated += 1;
      break;
    }

    chunks.push(chunk);
    total += chunk.length;
  }

  return { diff: chunks.join('\n'), truncated };
}

function buildPrompt(diff, truncated) {
  return `Eres un analizador estricto de arquitectura de software.

Analiza el git diff y devuelve SOLO un objeto JSON con esta forma:
{
  "entities": [{ "name": "string", "entityType": "string", "observations": ["string"] }],
  "relations": [{ "from": "string", "to": "string", "relationType": "string" }],
  "candidateDeletions": ["string"]
}

Reglas:
- entityType permitido: ${[...ALLOWED_ENTITY_TYPES].join(', ')}.
- relationType permitido: ${[...ALLOWED_RELATION_TYPES].join(', ')}.
- observations: contrato observable (firma pública, colección, límite de paginación, invariante). Máximo 2 por entidad. Nada de detalles de implementación.
- candidateDeletions: solo entidades que el diff elimine o renombre de forma inequívoca.
${truncated > 0 ? '- ATENCIÓN: el diff está truncado. NO propongas candidatos a borrado de archivos parciales.\n' : ''}
- Si el diff no cambia contratos, devuelve arrays vacíos.

Git diff:
${diff}
`;
}

async function extractWithLlm(prompt) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error('Falta OPENAI_API_KEY. Configúrala como secret del repositorio.');
  }

  const response = await fetch(`${BASE_URL}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: MODEL,
      messages: [{ role: 'user', content: prompt }],
      response_format: { type: 'json_object' },
      temperature: 0.1,
    }),
  });

  if (!response.ok) {
    throw new Error(`API LLM respondió ${response.status}: ${await response.text()}`);
  }

  const payload = await response.json();
  const text = payload?.choices?.[0]?.message?.content;
  if (!text) {
    throw new Error('Respuesta del LLM vacía o sin choices[0].message.content.');
  }

  return JSON.parse(text);
}

/** true si el identificador sigue apareciendo en el código versionado. */
function stillInCode(name) {
  // Solo rutas que existen: un pathspec inexistente hace fallar git grep y
  // convertiría el fallo en un borrado por accidente.
  const paths = ['lib', 'functions/src', 'firestore.rules'].filter((candidate) =>
    fs.existsSync(path.resolve(process.cwd(), candidate)),
  );
  if (paths.length === 0) return true;

  try {
    git(['grep', '-F', '-i', '-q', '-e', name, '--', ...paths], { stdio: 'ignore' });
    return true;
  } catch (error) {
    if (error.status === 1) return false; // sin coincidencias
    // Cualquier otro fallo (repo corrupto, permisos) no autoriza borrar.
    console.warn(`[aviso] git grep falló para "${name}" (status ${error.status}); se conserva la entidad.`);
    return true;
  }
}

function readGraph() {
  if (!fs.existsSync(GRAPH_FILE)) {
    return { graph: { entities: [], relations: [] }, existed: false };
  }
  const text = fs.readFileSync(GRAPH_FILE, 'utf8');
  try {
    return { graph: parseGraph(text), existed: true };
  } catch (error) {
    throw new Error(`El grafo existente no se puede parsear y NO se sobrescribirá: ${error.message}`);
  }
}

async function main() {
  if (!BASE_COMMIT || /^0+$/.test(BASE_COMMIT)) {
    console.log('Push inicial o commit base desconocido: nada que comparar.');
    return;
  }

  const files = listChangedContractFiles();
  if (files.length === 0) {
    console.log('Sin cambios en archivos de contrato.');
    return;
  }

  console.log(`Analizando ${files.length} archivo(s) de contrato...`);

  const { diff, truncated } = buildDiff(files);
  if (!diff.trim()) {
    console.log('El diff de contratos está vacío.');
    return;
  }

  const { graph, existed } = readGraph();
  console.log(`Grafo actual: ${existed ? `${graph.entities.length} entidades, ${graph.relations.length} relaciones` : 'no existe todavía'}.`);

  const rawUpdates = await extractWithLlm(buildPrompt(diff, truncated));
  const updates = validateUpdates(rawUpdates);

  // Verificación de borrados contra el código real.
  const existingNames = new Map(graph.entities.map((entity) => [entity.name.toLowerCase(), entity]));
  const confirmedDeletions = new Set();
  const rejected = [];

  for (const candidate of updates.deletedEntities) {
    const key = candidate.toLowerCase();
    const entity = existingNames.get(key);

    if (!entity) continue;
    if (!DELETABLE_TYPES.has(entity.entityType)) {
      rejected.push(`${candidate} (${entity.entityType}: concepto, no símbolo)`);
      continue;
    }
    if (stillInCode(candidate)) {
      rejected.push(`${candidate} (sigue en el código)`);
      continue;
    }
    confirmedDeletions.add(candidate);
  }

  if (rejected.length > 0) {
    console.log('Borrados rechazados por la verificación:');
    for (const item of rejected) console.log(`  - ${item}`);
  }

  // El diff truncado invalida los candidatos a borrado que no se hayan podido
  // verificar con seguridad.
  if (truncated > 0 && updates.deletedEntities.length > 0) {
    console.log(`[aviso] diff truncado en ${truncated} punto(s): no se aplicará ningún borrado.`);
  }

  const { graph: merged, stats, pruned } = mergeUpdates(graph, updates, {
    confirmedDeletions: truncated > 0 ? new Set() : confirmedDeletions,
  });

  for (const relation of pruned) {
    console.log(`[poda] ${relation.from} -> ${relation.to} (${relation.relationType})`);
  }

  const nextText = serializeGraph(merged);
  const previousText = existed ? fs.readFileSync(GRAPH_FILE, 'utf8') : '';

  if (nextText === previousText) {
    console.log('Sin cambios reales en el grafo.');
    return;
  }

  fs.mkdirSync(path.dirname(GRAPH_FILE), { recursive: true });
  fs.writeFileSync(GRAPH_FILE, nextText, 'utf8');

  console.log(
    `Grafo actualizado: +${stats.entitiesAdded} entidades, ~${stats.entitiesUpdated} actualizadas, ` +
      `-${stats.entitiesDeleted} borradas, +${stats.relationsAdded} relaciones, ` +
      `${stats.relationsPruned} aristas podadas. Total: ${merged.entities.length} entidades, ` +
      `${merged.relations.length} relaciones.`,
  );
}

main().catch((error) => {
  console.error(`[FATAL] ${error.message}`);
  process.exit(1);
});
