import { test } from 'node:test';
import assert from 'node:assert/strict';
import { CAMPOS_PRIVADOS, planMigracion } from './privateAccount';

test('sin email ni fcmToken no hay nada que migrar', () => {
  assert.equal(planMigracion('u1', { nombre: 'Ana' }), null);
});

test('con email y fcmToken copia los dos y los borra del documento público', () => {
  const plan = planMigracion('u1', { nombre: 'Ana', email: 'a@b.c', fcmToken: 'tok' });
  assert.ok(plan);
  assert.deepEqual(plan.copiar, { email: 'a@b.c', fcmToken: 'tok' });
  assert.deepEqual(plan.borrar, ['email', 'fcmToken']);
  assert.deepEqual(plan.omitidos, []);
});

test('si el documento privado ya tiene el campo, gana el documento privado', () => {
  const plan = planMigracion(
    'u1',
    { email: 'a@b.c', fcmToken: 'viejo' },
    { email: 'a@b.c', fcmToken: 'nuevo' },
  );
  assert.ok(plan);
  assert.deepEqual(plan.copiar, {});
  assert.deepEqual(plan.borrar, ['email', 'fcmToken']);
  assert.deepEqual(plan.omitidos, ['email', 'fcmToken']);
});

test('los valores vacíos se ignoran', () => {
  assert.equal(planMigracion('u1', { email: '', fcmToken: null }), null);
  assert.equal(planMigracion('u1', { email: '   ' }), null);
});

test('la migración es idempotente: un perfil ya migrado no propone nada', () => {
  const plan = planMigracion('u1', { nombre: 'Ana' }, { email: 'a@b.c' });
  assert.equal(plan, null);
});

test('CAMPOS_PRIVADOS cubre email y fcmToken', () => {
  assert.deepEqual([...CAMPOS_PRIVADOS], ['email', 'fcmToken']);
});
