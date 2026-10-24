#!/usr/bin/env node
// Envoltorio para la GitHub App de una sesión.
// Uso: node scripts/gh-app.mjs <sesion> <comando gh> [args...]
// Obtiene el token de instalación de la app de la sesión, lo expone como
// GH_TOKEN (solo en memoria, nunca a fichero) y ejecuta `gh`.
import { execSync } from 'child_process';

const session = process.argv[2];
let ghArgs = process.argv.slice(3);

// El usuario invoca: node scripts/gh-app.mjs <sesion> gh <subcommand> ...
// Descartamos el "gh" literal si viene como primer argumento.
if (ghArgs[0] === 'gh') {
  ghArgs = ghArgs.slice(1);
}

if (!session || ghArgs.length === 0) {
  console.error('Uso: node scripts/gh-app.mjs <sesion> <comando gh> [args...]');
  process.exit(1);
}

let token;
try {
  token = execSync(`node scripts/gh-app-token.mjs ${session}`, {
    encoding: 'utf8',
    stdio: ['pipe', 'pipe', 'pipe'],
  }).trim();
} catch (e) {
  console.error(`ERROR: no se pudo obtener el token de la app "${session}"`);
  process.exit(1);
}

if (!token) {
  console.error(`ERROR: token vacío para la sesión "${session}"`);
  process.exit(1);
}

// Solo en memoria del proceso, nunca a disco.
process.env.GH_TOKEN = token;

try {
  execSync(`gh ${ghArgs.join(' ')}`, {
    stdio: 'inherit',
    encoding: 'utf8',
  });
} catch (e) {
  process.exit(e.status ?? 1);
}
