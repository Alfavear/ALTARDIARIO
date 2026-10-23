import type { Firestore } from 'firebase-admin/firestore';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { procesarReporte, type ResolvedorComentario } from './moderation';

// ----------------------------- Fake de Firestore -----------------------------

interface FakeDocData {
  [key: string]: any;
}

class FakeDocSnap {
  constructor(
    public readonly path: string,
    public readonly exists: boolean,
    private readonly dataValue: FakeDocData,
  ) {}
  data(): FakeDocData {
    return this.dataValue;
  }
  get(field: string): any {
    return this.dataValue[field];
  }
  get ref() {
    return { path: this.path };
  }
}

class FakeQuerySnap {
  constructor(public readonly docs: FakeDocSnap[]) {}
  get empty(): boolean {
    return this.docs.length === 0;
  }
}

class FakeDocRef {
  constructor(
    public readonly path: string,
    private readonly db: FakeDb,
  ) {}
  async get(): Promise<FakeDocSnap> {
    const [coleccion, ...rest] = this.path.split('/');
    const id = rest.pop()!;
    const padre = rest.join('/');
    const colPath = padre ? `${coleccion}/${padre}` : coleccion;
    const docs = this.db.store.get(colPath) ?? [];
    const doc = docs.find((d) => d.id === id);
    return new FakeDocSnap(this.path, !!doc, doc ?? {});
  }
  async set(data: any, _options?: any): Promise<void> {
    this.db.writes.push({ path: this.path, data });
  }
}

class FakeCollectionRef {
  constructor(private readonly db: FakeDb, public readonly path: string) {}
  private wheres: Array<{ field: string; op: string; value: any }> = [];
  where(field: string, op: string, value: any): this {
    this.wheres.push({ field, op, value });
    return this;
  }
  async get(): Promise<FakeQuerySnap> {
    const docsRaw = this.db.store.get(this.path) ?? [];
    let docs = docsRaw.map(
      (d) =>
        new FakeDocSnap(`${this.path}/${d.id}`, true, d) as FakeDocSnap,
    );
    if (this.wheres.length > 0) {
      docs = docs.filter((d) =>
        this.wheres.every((w) => d.get(w.field) === w.value),
      );
    }
    return new FakeQuerySnap(docs);
  }
  doc(subPath: string): FakeDocRef {
    return new FakeDocRef(`${this.path}/${subPath}`, this.db);
  }
}

class FakeGroupQuery {
  constructor(private readonly db: FakeDb, private readonly group: string) {}
  private docId: string | null = null;
  where(_fieldPath: any, _op: string, value: any): this {
    // En collectionGroup solo hacemos consultas por ID de documento (FieldPath.documentId()).
    // Capturamos el valor directamente.
    this.docId = value;
    return this;
  }
  limit(_n: number): this {
    return this;
  }
  async get(): Promise<FakeQuerySnap> {
    if (!this.docId) return new FakeQuerySnap([]);
    const encontrado: FakeDocSnap[] = [];
    for (const [colPath, docsRaw] of this.db.store) {
      if (!colPath.includes(`/${this.group}/`)) continue;
      const doc = docsRaw.find((d) => d.id === this.docId);
      if (doc) {
        encontrado.push(new FakeDocSnap(`${colPath}/${doc.id}`, true, doc));
        break;
      }
    }
    return new FakeQuerySnap(encontrado);
  }
}

class FakeDb {
  store = new Map<string, any[]>();
  writes: Array<{ path: string; data: any }> = [];

  collection(path: string): FakeCollectionRef {
    return new FakeCollectionRef(this, path);
  }
  doc(path: string): FakeDocRef {
    return new FakeDocRef(path, this);
  }
  collectionGroup(group: string): FakeGroupQuery {
    return new FakeGroupQuery(this, group);
  }
}

function seed(db: FakeDb, coleccion: string, id: string, data: any): void {
  const col = db.store.get(coleccion) ?? [];
  col.push({ id, ...data });
  db.store.set(coleccion, col);
}

function seedReportes(
  db: FakeDb,
  targetType: string,
  targetId: string,
  reporteres: string[],
): void {
  const col = db.store.get('reports') ?? [];
  for (const reporterId of reporteres) {
    col.push({
      id: `rep_${reporterId}_${targetId}`,
      reporterId,
      targetType,
      targetId,
      reason: 'Spam',
    });
  }
  db.store.set('reports', col);
}

function ultimoSet(db: FakeDb) {
  return db.writes[db.writes.length - 1];
}

// ----------------------------- Tests -----------------------------

test('procesarReporte: reflexion oculta tras 3 reportes', async () => {
  const db = new FakeDb();
  seed(db, 'reflexiones', 'r1', { texto: 'Hola' });
  seedReportes(db, 'reflexion', 'r1', ['a', 'b', 'c']);
  await procesarReporte(db as unknown as Firestore, {
    targetType: 'reflexion',
    targetId: 'r1',
    reporterId: 'c',
    reason: 'Spam',
  });
  const w = ultimoSet(db);
  assert.equal(w.path, 'reflexiones/r1');
  assert.equal(w.data.hidden, true);
  assert.equal(w.data.hiddenReason, 'reports');
});

test('procesarReporte: peticion oculta tras 3 reportes', async () => {
  const db = new FakeDb();
  seed(db, 'peticiones_oracion', 'p1', { motivo: 'Ayuda' });
  seedReportes(db, 'peticion', 'p1', ['a', 'b', 'c']);
  await procesarReporte(db as unknown as Firestore, {
    targetType: 'peticion',
    targetId: 'p1',
    reporterId: 'c',
    reason: 'Spam',
  });
  assert.equal(ultimoSet(db)!.path, 'peticiones_oracion/p1');
  assert.equal(ultimoSet(db)!.data.hidden, true);
});

test('procesarReporte: debate oculta tras 3 reportes', async () => {
  const db = new FakeDb();
  seed(db, 'debates', 'd1', { titulo: 'T' });
  seedReportes(db, 'debate', 'd1', ['a', 'b', 'c']);
  await procesarReporte(db as unknown as Firestore, {
    targetType: 'debate',
    targetId: 'd1',
    reporterId: 'c',
    reason: 'Spam',
  });
  assert.equal(ultimoSet(db)!.path, 'debates/d1');
  assert.equal(ultimoSet(db)!.data.hidden, true);
});

test('procesarReporte: usuario oculta su perfil tras 3 reportes', async () => {
  const db = new FakeDb();
  seed(db, 'usuarios', 'u1', { nombre: 'Ana' });
  seedReportes(db, 'usuario', 'u1', ['a', 'b', 'c']);
  await procesarReporte(db as unknown as Firestore, {
    targetType: 'usuario',
    targetId: 'u1',
    reporterId: 'c',
    reason: 'Spam',
  });
  assert.equal(ultimoSet(db)!.path, 'usuarios/u1');
  assert.equal(ultimoSet(db)!.data.hidden, true);
});

test('procesarReporte: comentario resuelve ruta real y oculta', async () => {
  const db = new FakeDb();
  seed(db, 'reflexiones', 'r1', { texto: 'Hola' });
  seedReportes(db, 'comentario', 'c1', ['a', 'b', 'c']);
  const resolverMock: ResolvedorComentario = async (_db, commentId) =>
    commentId === 'c1' ? 'reflexiones/r1/comentarios/c1' : null;
  await procesarReporte(db as unknown as Firestore, {
    targetType: 'comentario',
    targetId: 'c1',
    reporterId: 'c',
    reason: 'Spam',
  }, resolverMock);
  const w = ultimoSet(db);
  assert.equal(w!.path, 'reflexiones/r1/comentarios/c1');
  assert.equal(w!.data.hidden, true);
});

test('procesarReporte: menos de 3 reportes no oculta', async () => {
  const db = new FakeDb();
  seed(db, 'reflexiones', 'r1', { texto: 'Hola' });
  seedReportes(db, 'reflexion', 'r1', ['a']);
  await procesarReporte(db as unknown as Firestore, {
    targetType: 'reflexion',
    targetId: 'r1',
    reporterId: 'b',
    reason: 'Spam',
  });
  assert.equal(db.writes.length, 0, 'no debe escribir hidden con menos de 3');
});

test('procesarReporte: target inexistente no lanza ni escribe', async () => {
  const db = new FakeDb();
  seed(db, 'reflexiones', 'r1', { texto: 'Hola' });
  await assert.doesNotReject(
    procesarReporte(db as unknown as Firestore, {
      targetType: 'reflexion',
      targetId: 'noexiste',
      reporterId: 'x',
      reason: 'Spam',
    }),
  );
  assert.equal(db.writes.length, 0);
});

test('procesarReporte: comentario inexistente no lanza ni escribe', async () => {
  const db = new FakeDb();
  seed(db, 'reflexiones', 'r1', { texto: 'Hola' });
  const resolverMock: ResolvedorComentario = async () => null;
  await assert.doesNotReject(
    procesarReporte(db as unknown as Firestore, {
      targetType: 'comentario',
      targetId: 'noexiste',
      reporterId: 'x',
      reason: 'Spam',
    }, resolverMock),
  );
  assert.equal(db.writes.length, 0);
});

test('procesarReporte: targetType desconocido no lanza ni escribe', async () => {
  const db = new FakeDb();
  await assert.doesNotReject(
    procesarReporte(db as unknown as Firestore, {
      targetType: 'otro',
      targetId: 'x',
      reporterId: 'x',
      reason: 'Spam',
    }),
  );
  assert.equal(db.writes.length, 0);
});
