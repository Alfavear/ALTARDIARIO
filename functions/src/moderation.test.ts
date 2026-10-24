import assert from 'node:assert/strict';
import test from 'node:test';

import { decidirAccionModeracion } from './moderation';

test('no activa moderación antes de tres reporteros distintos', () => {
  assert.equal(decidirAccionModeracion('usuario', 2), 'ignorar');
  assert.equal(decidirAccionModeracion('reflexion', 2), 'ignorar');
});

test('envía perfiles reportados a revisión humana al alcanzar el umbral', () => {
  assert.equal(decidirAccionModeracion('usuario', 3), 'revisar_usuario');
  assert.equal(decidirAccionModeracion('usuario', 5), 'revisar_usuario');
});

test('oculta contenido compatible al alcanzar el umbral', () => {
  assert.equal(decidirAccionModeracion('reflexion', 3), 'ocultar_contenido');
  assert.equal(decidirAccionModeracion('peticion', 3), 'ocultar_contenido');
  assert.equal(decidirAccionModeracion('debate', 3), 'ocultar_contenido');
});

test('ignora tipos de objetivo desconocidos', () => {
  assert.equal(decidirAccionModeracion('desconocido', 3), 'ignorar');
});
