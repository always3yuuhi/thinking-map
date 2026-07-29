import '../database/app_database.dart';
import '../models/location_log.dart';

class LocationLogRepository {
  LocationLogRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> insert(LocationLog log) async {
    final db = await _database.database;
    final map = log.toMap()..remove('id');
    return db.insert('location_logs', map);
  }

  Future<List<LocationLog>> findBetween(DateTime start, DateTime end) async {
    final db = await _database.database;
    final rows = await db.query(
      'location_logs',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp ASC',
    );
    return rows.map(LocationLog.fromMap).toList();
  }

  Future<void> deleteOlderThan(DateTime cutoff) async {
    final db = await _database.database;
    await db.delete(
      'location_logs',
      where: 'timestamp < ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }
}
