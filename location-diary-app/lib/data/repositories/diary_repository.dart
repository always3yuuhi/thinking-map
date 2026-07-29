import '../database/app_database.dart';
import '../models/diary_entry.dart';

class DiaryRepository {
  DiaryRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> upsert(DiaryEntry entry) async {
    final db = await _database.database;
    final normalized = entry.copyWith(date: DiaryEntry.dateOnly(entry.date));
    final map = normalized.toMap()..remove('id');
    final existing = await findByDate(normalized.date);
    if (existing == null) {
      return db.insert('diary_entries', map);
    }
    await db.update(
      'diary_entries',
      map,
      where: 'id = ?',
      whereArgs: [existing.id],
    );
    return existing.id!;
  }

  Future<DiaryEntry?> findByDate(DateTime date) async {
    final db = await _database.database;
    final rows = await db.query(
      'diary_entries',
      where: 'date = ?',
      whereArgs: [DiaryEntry.dateOnly(date).toIso8601String()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DiaryEntry.fromMap(rows.first);
  }

  Future<List<DiaryEntry>> findAll() async {
    final db = await _database.database;
    final rows = await db.query('diary_entries', orderBy: 'date DESC');
    return rows.map(DiaryEntry.fromMap).toList();
  }
}
