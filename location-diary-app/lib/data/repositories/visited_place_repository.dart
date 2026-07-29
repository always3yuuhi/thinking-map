import '../database/app_database.dart';
import '../models/visited_place.dart';

class VisitedPlaceRepository {
  VisitedPlaceRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> insert(VisitedPlace place) async {
    final db = await _database.database;
    final map = place.toMap()..remove('id');
    return db.insert('visited_places', map);
  }

  Future<void> update(VisitedPlace place) async {
    final db = await _database.database;
    await db.update(
      'visited_places',
      place.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [place.id],
    );
  }

  Future<List<VisitedPlace>> findBetween(DateTime start, DateTime end) async {
    final db = await _database.database;
    final rows = await db.query(
      'visited_places',
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'start_time ASC',
    );
    return rows.map(VisitedPlace.fromMap).toList();
  }

  Future<void> setAlias(int visitedPlaceId, int? aliasId) async {
    final db = await _database.database;
    await db.update(
      'visited_places',
      {'alias_id': aliasId},
      where: 'id = ?',
      whereArgs: [visitedPlaceId],
    );
  }
}
