import { test } from 'node:test';
import assert from 'node:assert/strict';
import * as R from './roadmap.mjs';

const fixture = () => ({
  meta: { current_phase: 1, cycle_counter: 0, phases: { 1: 'uno' } },
  tasks: [
    { id: 'T-001', title: 'a', type: 'infra', phase: 1, priority: 'P1', effort: 'S', status: 'done', acceptance: ['x'] },
    { id: 'T-002', title: 'b', type: 'test', phase: 1, priority: 'P0', effort: 'M', status: 'backlog', depends_on: ['T-001'], acceptance: ['x'] },
    { id: 'T-003', title: 'c', type: 'feature', phase: 1, priority: 'P0', effort: 'S', status: 'backlog', depends_on: ['T-002'], acceptance: ['x'] },
    { id: 'T-004', title: 'd', type: 'refactor', phase: 1, priority: 'P2', effort: 'L', status: 'ready', acceptance: ['x'] },
  ],
});

test('validate: fixture válido', () => assert.deepEqual(R.validate(fixture()), []));
test('next_task respeta dependencias y prioridad', () => assert.equal(R.nextTask(fixture()).task.id, 'T-002'));
test('next_task nunca elige L', () => { const d = fixture(); d.tasks[1].status = 'done'; d.tasks[2].status = 'done'; assert.equal(R.nextTask(d).task, null); });
test('start/complete exige evidencia y una sola in_progress', () => {
  const d = fixture();
  R.startTask(d, 'T-002', 1);
  assert.throws(() => R.startTask(d, 'T-004', 1), /in_progress/);
  assert.throws(() => R.completeTask(d, 'T-002', { evidence: 'ok' }), /evidence/);
  R.completeTask(d, 'T-002', { evidence: 'scripts/check.sh: ✔ Todo en verde. 108 tests passed' });
  assert.equal(d.tasks[1].status, 'done');
  assert.equal(R.nextTask(d).task.id, 'T-003');
});
test('add_task valida y asigna id', () => { const d = fixture(); const t = R.addTask(d, { title: 'n', type: 'bug', acceptance: ['y'] }); assert.equal(t.id, 'T-005'); assert.throws(() => R.addTask(d, { title: 'z', type: 'bug', acceptance: [] })); });
test('split_task encadena partes y dropea la original', () => {
  const d = fixture();
  const parts = R.splitTask(d, 'T-004', [{ title: 'p1', acceptance: ['a'] }, { title: 'p2', acceptance: ['b'] }]);
  assert.equal(d.tasks[3].status, 'dropped');
  assert.deepEqual(parts[1].depends_on, [parts[0].id]);
});
