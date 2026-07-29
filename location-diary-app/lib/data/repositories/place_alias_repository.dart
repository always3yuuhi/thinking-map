import '../database/app_database.dart';
import '../models/place_alias.dart';

class PlaceAliasRepository {
  PlaceAliasRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> insert(PlaceAlias alias) async {
    final db = await _database.database;
    final map = alias.toMap()..remove('id');
    return db.insert('place_aliases', map);
  }

  Future<void> update(PlaceAlias alias) async {
    final db = await _database.database;
    await db.update(
      'place_aliases',
      alias.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [alias.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _database.database;
    await db.delete('place_aliases', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PlaceAlias>> findAll() async {
    final db = await _database.database;
    final rows = await db.query('place_aliases', orderBy: 'display_name ASC');
    return rows.map(PlaceAlias.fromMap).toList();
  }
}
