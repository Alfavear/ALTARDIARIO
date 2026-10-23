import { execFileSync } from 'node:child_process';

// En Windows, dart/flutter son .bat y execFileSync no los ejecuta sin shell.
const shell = process.platform === 'win32';

console.log('⚡ Iniciando verificación rápida de calidad y formato...');

try {
  console.log('1. Verificando formato de código Dart...');
  execFileSync('dart', ['format', '--output=none', '--set-exit-if-changed', 'lib/'], {
    stdio: 'inherit',
    shell,
  });

  console.log('2. Ejecutando análisis estático (Flutter Analyze)...');
  execFileSync('flutter', ['analyze', '--no-fatal-infos'], {
    stdio: 'inherit',
    shell,
  });

  console.log('✔ Árbol de trabajo en estado óptimo y sin errores de análisis.');
  process.exit(0);
} catch (error) {
  console.error('\n❌ Falló la verificación previa. Corrige las advertencias antes de avanzar.');
  process.exit(1);
}
