import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens and migrates the app's local SQLite database.
///
/// Kept as a thin singleton wrapper so repositories can share one
/// connection without threading a Database instance through the widget
/// tree via constructor parameters everywhere.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'location_diary.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE location_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            activity_type TEXT NOT NULL DEFAULT 'unknown'
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_location_logs_timestamp ON location_logs(timestamp)',
        );

        await db.execute('''
          CREATE TABLE place_aliases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            radius_meters REAL NOT NULL DEFAULT 100,
            display_name TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE visited_places (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            start_time TEXT NOT NULL,
            end_time TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            resolved_address TEXT,
            alias_id INTEGER REFERENCES place_aliases(id) ON DELETE SET NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_visited_places_start_time ON visited_places(start_time)',
        );

        await db.execute('''
          CREATE TABLE diary_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL UNIQUE,
            body TEXT NOT NULL,
            manually_edited INTEGER NOT NULL DEFAULT 0,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
