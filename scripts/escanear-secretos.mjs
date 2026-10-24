#!/usr/bin/env node
// Falla si un cambio añade un secreto o un fichero que no debe llegar al repositorio (que es público).
//
//   node scripts/escanear-secretos.mjs [--base origin/main]
//
// Revisa solo lo que AÑADE el cambio (git diff base...HEAD): líneas con tokens/claves conocidos y nombres de
// fichero prohibidos. Complementa el escaneo y la protección de push de GitHub, que ya rechazan los
// formatos que GitHub reconoce. Sin dependencias. Se ejecuta en .github/workflows/secretos.yml.
import { spawnSync } from 'node:child_process';

const i = process.argv.indexOf('--base');
const base = i > 0 ? process.argv[i + 1] : 'origin/main';
const git = (...a) => spawnSync('git', a, { encoding: 'utf8', maxBuffer: 256 * 1024 * 1024 });

const PATRONES = [
  ['token de GitHub', /\bgh[pour]_[A-Za-z0-9_]{20,}/],
  ['token de instalación de app de GitHub', /\bghs_[A-Za-z0-9_.-]{30,}/],
  ['token fino de GitHub', /\bgithub_pat_[A-Za-z0-9_]{30,}/],
  ['clave de NVIDIA', /\bnvapi-[A-Za-z0-9_-]{20,}/],
  ['clave de API de Google', /\bAIza[0-9A-Za-z_-]{35}\b/],
  ['clave privada', /-----BEGIN (?:[A-Z]+ )?PRIVATE KEY-----/],
  ['clave de OpenAI/Anthropic', /\bsk-(?:ant-)?[A-Za-z0-9_-]{32,}/],
  ['token de Slack', /\bxox[baprs]-[A-Za-z0-9-]{10,}/],
  ['JWT', /\beyJ[A-Za-z0-9_-]{15,}\.eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{10,}/],
];
const FICHEROS = [
  [/(^|\/)token[^/]*\.txt$/i, 'fichero de token'],
  [/\.(pem|token|jks|keystore|p12|pfx)$/i, 'clave o almacén de claves'],
  [/(^|\/)\.env(\.(?!example$)[^/]+)?$/, 'fichero .env'],
  [/(^|\/)key\.properties$/, 'key.properties de Android'],
  [/(^|\/)(google-services\.json|GoogleService-Info\.plist)$/, 'configuración de Firebase con claves'],
];

const hallazgos = [];
const nombres = git('diff', '--name-only', '--diff-filter=AM', `${base}...HEAD`).stdout.split('\n').filter(Boolean);
for (const f of nombres) for (const [re, que] of FICHEROS) if (re.test(f)) hallazgos.push(`${f}: ${que}`);

let fichero = ''; let linea = 0;
for (const l of git('diff', '--unified=0', '--no-color', `${base}...HEAD`).stdout.split('\n')) {
  if (l.startsWith('+++ b/')) { fichero = l.slice(6); continue; }
  const h = /^@@ -\S+ \+(\d+)/.exec(l); if (h) { linea = Number(h[1]); continue; }
  if (!l.startsWith('+') || l.startsWith('+++')) continue;
  for (const [que, re] of PATRONES) {
    const m = re.exec(l);
    if (m) hallazgos.push(`${fichero}:${linea}: ${que} («${m[0].slice(0, 6)}…», ${m[0].length} caracteres)`);
  }
  linea++;
}

if (hallazgos.length) {
  console.error(`✗ Posibles secretos en el cambio (${hallazgos.length}):\n  ${hallazgos.join('\n  ')}`);
  console.error('\nQuita el secreto del commit (reescribiendo la rama aún sin mergear), usa una variable de entorno o un secret de GitHub, y rota la credencial si llegó a empujarse.');
  process.exit(1);
}
console.log(`✔ Sin secretos en lo añadido (${nombres.length} ficheros revisados frente a ${base}).`);
