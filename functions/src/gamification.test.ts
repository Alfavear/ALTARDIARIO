import { test } from 'node:test';
import assert from 'node:assert/strict';
import { nivelPara, NIVELES } from './gamification';

test('nivelPara: 0 XP es nivel 1', () => assert.equal(nivelPara(0), 1));
test('nivelPara: umbral exacto sube de nivel', () => assert.equal(nivelPara(NIVELES[1]), 2));
test('nivelPara: tope en el último nivel', () => assert.equal(nivelPara(999999), NIVELES.length));
