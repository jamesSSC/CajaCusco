import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton que gestiona la base de datos SQLite local.
/// Siguiendo el patrón offline-first del roadmap.
class LocalDb {
  LocalDb._();
  static final LocalDb instance = LocalDb._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  /// Llamar en main() antes de runApp para garantizar que la BD esté lista.
  Future<void> init() async {
    _db = await _open();
  }

  Future<Database> _open() async {
    final dbPath = join(await getDatabasesPath(), 'cajacusco_v1.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ── Cola offline: visitas pendientes de sync ──────────────────────────
    await db.execute('''
      CREATE TABLE visitas_pendientes (
        id TEXT PRIMARY KEY,
        cartero_id TEXT NOT NULL,
        resultado TEXT NOT NULL,
        observacion TEXT,
        timestamp_visita TEXT NOT NULL,
        lat REAL,
        lng REAL,
        pendiente_sync INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // ── Cola offline: borradores de solicitudes ───────────────────────────
    await db.execute('''
      CREATE TABLE solicitudes_borrador (
        id TEXT PRIMARY KEY,
        cliente_id TEXT,
        cliente_nombre TEXT,
        paso_actual INTEGER NOT NULL DEFAULT 1,
        datos_json TEXT NOT NULL,
        monto_solicitado REAL,
        asesor_id TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // ── Caché: cartera diaria ─────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE cartera_cache (
        id TEXT PRIMARY KEY,
        asesor_id TEXT NOT NULL,
        cliente_id TEXT NOT NULL,
        agencia_id TEXT,
        fecha_asignacion TEXT NOT NULL,
        tipo_gestion TEXT NOT NULL,
        prioridad TEXT NOT NULL,
        score_prioridad INTEGER NOT NULL DEFAULT 0,
        estado_visita TEXT NOT NULL DEFAULT 'pendiente',
        resultado_visita TEXT,
        observacion_visita TEXT,
        timestamp_visita TEXT,
        lat_visita REAL,
        lng_visita REAL,
        orden_manual INTEGER,
        cliente_nombre TEXT,
        cliente_documento TEXT,
        monto_credito REAL,
        cliente_telefono TEXT,
        cliente_lat REAL,
        cliente_lng REAL,
        synced_at TEXT
      )
    ''');

    // ── Caché: fichas de clientes ─────────────────────────────────────────
    await db.execute('''
      CREATE TABLE fichas_cache (
        cliente_id TEXT PRIMARY KEY,
        datos_json TEXT NOT NULL,
        synced_at TEXT NOT NULL
      )
    ''');

    // ── Caché: historial de pagos (para gráfico offline) ─────────────────
    await db.execute('''
      CREATE TABLE pagos_cache (
        id TEXT PRIMARY KEY,
        cliente_id TEXT NOT NULL,
        mes TEXT NOT NULL,
        estado_pago TEXT NOT NULL,
        monto REAL,
        dias_mora INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── Caché: alertas de cartera ─────────────────────────────────────────
    await db.execute('''
      CREATE TABLE alertas_cache (
        id TEXT PRIMARY KEY,
        asesor_id TEXT NOT NULL,
        cliente_id TEXT NOT NULL,
        tipo_alerta TEXT NOT NULL,
        mensaje TEXT,
        leida INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ── Limpieza selectiva de datos sensibles (al cerrar sesión) ─────────────

  Future<void> clearAllSensitiveData() async {
    final d = await db;
    final batch = d.batch();
    batch.delete('cartera_cache');
    batch.delete('fichas_cache');
    batch.delete('pagos_cache');
    batch.delete('alertas_cache');
    batch.delete('visitas_pendientes');
    batch.delete('solicitudes_borrador');
    await batch.commit(noResult: true);
  }

  Future<void> clearCarteraCache(String asesorId) async {
    final d = await db;
    await d.delete(
      'cartera_cache',
      where: 'asesor_id = ?',
      whereArgs: [asesorId],
    );
  }

  // ── Visitas pendientes ────────────────────────────────────────────────────

  Future<void> insertVisitaPendiente(Map<String, dynamic> data) async {
    final d = await db;
    await d.insert('visitas_pendientes', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getVisitasPendientes() async {
    final d = await db;
    return d.query('visitas_pendientes',
        where: 'pendiente_sync = 1');
  }

  Future<void> markVisitaSincronizada(String id) async {
    final d = await db;
    await d.update(
      'visitas_pendientes',
      {'pendiente_sync': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Borradores ────────────────────────────────────────────────────────────

  Future<void> upsertBorrador(Map<String, dynamic> data) async {
    final d = await db;
    await d.insert('solicitudes_borrador', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getBorradores(String asesorId) async {
    final d = await db;
    return d.query(
      'solicitudes_borrador',
      where: 'asesor_id = ?',
      whereArgs: [asesorId],
      orderBy: 'updated_at DESC',
    );
  }

  Future<void> deleteBorrador(String id) async {
    final d = await db;
    await d.delete('solicitudes_borrador', where: 'id = ?', whereArgs: [id]);
  }

  // ── Cartera caché ─────────────────────────────────────────────────────────

  Future<void> upsertCarteraItems(List<Map<String, dynamic>> items) async {
    final d = await db;
    final batch = d.batch();
    for (final item in items) {
      batch.insert('cartera_cache', item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCartera(
      String asesorId, String fecha) async {
    final d = await db;
    return d.query(
      'cartera_cache',
      where: 'asesor_id = ? AND fecha_asignacion = ?',
      whereArgs: [asesorId, fecha],
      orderBy: 'orden_manual ASC, score_prioridad DESC',
    );
  }

  Future<void> updateEstadoVisita(
      String id, Map<String, dynamic> data) async {
    final d = await db;
    await d.update('cartera_cache', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countPendienteSync() async {
    final d = await db;
    final result = await d.rawQuery(
      "SELECT COUNT(*) as c FROM visitas_pendientes WHERE pendiente_sync = 1",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
