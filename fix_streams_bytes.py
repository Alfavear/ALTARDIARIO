with open('lib/data/services/firestore_service.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Define replacements as tuples of (old, new)
replacements = [
    # reflexionesStream
    ("""  Stream<List<Reflexion>> reflexionesStream() {
    if (!_available) return Stream.value([]);
    return _reflexiones
        .orderBy('fecha', descending: true)
        .limit(feedPageSize)
        .snapshots()""",
     """  Stream<List<Reflexion>> reflexionesStream() {
    if (!_available) return Stream.value([]);
    return _reflexiones
        .where('oculto', isEqualTo: false)
        .orderBy('fecha', descending: true)
        .limit(feedPageSize)
        .snapshots()"""),
    
    # getUserReflexiones
    ("""  Stream<List<Reflexion>> getUserReflexiones(String userId) {
    if (!_available) return Stream.value([]);
    return _reflexiones
        .where('userId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .limit(userReflectionsPageSize)""",
     """  Stream<List<Reflexion>> getUserReflexiones(String userId) {
    if (!_available) return Stream.value([]);
    return _reflexiones
        .where('userId', isEqualTo: userId)
        .where('oculto', isEqualTo: false)
        .orderBy('fecha', descending: true)
        .limit(userReflectionsPageSize)"""),
    
    # getUserReflexionesWithUid
    ("""  Stream<List<Reflexion>> getUserReflexionesWithUid(String userId) {
    if (!_available) return Stream.value([]);
    return _reflexiones
        .where('userId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .limit(userReflectionsPageSize)""",
     """  Stream<List<Reflexion>> getUserReflexionesWithUid(String userId) {
    if (!_available) return Stream.value([]);
    return _reflexiones
        .where('userId', isEqualTo: userId)
        .where('oculto', isEqualTo: false)
        .orderBy('fecha', descending: true)
        .limit(userReflectionsPageSize)"""),
    
    # getUserReflexionesOnce
    ("""  Future<List<Reflexion>> getUserReflexionesOnce(String userId) async {
    if (!_available) return [];
    final snapshot = await _reflexiones
        .where('userId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .limit(50)""",
     """  Future<List<Reflexion>> getUserReflexionesOnce(String userId) async {
    if (!_available) return [];
    final snapshot = await _reflexiones
        .where('userId', isEqualTo: userId)
        .where('oculto', isEqualTo: false)
        .orderBy('fecha', descending: true)
        .limit(50)"""),
    
    # debatesStream
    ("""  Stream<List<Debate>> debatesStream({String? libroId}) {
    if (!_available) return Stream.value([]);
    var query = _debates.orderBy('fecha', descending: true) as Query;
    if (libroId != null && libroId.isNotEmpty) {
      query = query.where('libroId', isEqualTo: libroId);
    }
    query = query.limit(debatePageSize);""",
     """  Stream<List<Debate>> debatesStream({String? libroId}) {
    if (!_available) return Stream.value([]);
    var query = _debates
        .where('oculto', isEqualTo: false)
        .orderBy('fecha', descending: true) as Query;
    if (libroId != null && libroId.isNotEmpty) {
      query = query.where('libroId', isEqualTo: libroId);
    }
    query = query.limit(debatePageSize);"""),
    
    # debateRepliesStream
    ("""  Stream<List<DebateReply>> debateRepliesStream(String debateId) {
    if (!_available) return Stream.value([]);
    return _debateReplies(debateId)
        .orderBy('fecha', descending: false)
        .limit(debateRepliesPageSize)""",
     """  Stream<List<DebateReply>> debateRepliesStream(String debateId) {
    if (!_available) return Stream.value([]);
    return _debateReplies(debateId)
        .where('oculto', isEqualTo: false)
        .orderBy('fecha', descending: false)
        .limit(debateRepliesPageSize)"""),
    
    # peticionesStream
    ("""  Stream<List<PeticionOracion>> peticionesStream() {
    if (!_available) return Stream.value([]);
    return _peticiones
        .orderBy('fecha', descending: true)
        .limit(prayerPageSize)""",
     """  Stream<List<PeticionOracion>> peticionesStream() {
    if (!_available) return Stream.value([]);
    return _peticiones
        .where('oculto', isEqualTo: false)
        .orderBy('fecha', descending: true)
        .limit(prayerPageSize)"""),
    
    # peticionesStreamFiltrado
    ("""  Stream<List<PeticionOracion>> peticionesStreamFiltrado({bool? respondida}) {
    if (!_available) return Stream.value([]);
    Query query =
        _peticiones.orderBy('fecha', descending: true).limit(prayerPageSize);""",
     """  Stream<List<PeticionOracion>> peticionesStreamFiltrado({bool? respondida}) {
    if (!_available) return Stream.value([]);
    Query query =
        _peticiones.where('oculto', isEqualTo: false).orderBy('fecha', descending: true).limit(prayerPageSize);"""),
    
    # comentariosStream
    ("""  Stream<List<Comment>> comentariosStream(String reflexionId) {
    if (!_available) return Stream.value([]);
    return _reflexiones
        .doc(reflexionId)
        .collection('comentarios')
        .orderBy('fecha', descending: false)""",
     """  Stream<List<Comment>> comentariosStream(String reflexionId) {
    if (!_available) return Stream.value([]);
    return _reflexiones
        .doc(reflexionId)
        .collection('comentarios')
        .where('oculto', isEqualTo: false)
        .orderBy('fecha', descending: false)"""),
]

for old, new in replacements:
    if old in text:
        text = text.replace(old, new, 1)
        print(f'Applied replacement')
    else:
        print(f'NOT FOUND: {old[:50]}...')

with open('lib/data/services/firestore_service.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print('Done')