import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/video_summary.dart';

class DatabaseService {
  Database? _database;
  final Future<Database> Function(String path, {int? version, OnDatabaseCreateFn? onCreate})? _databaseFactory;

  DatabaseService({
    Future<Database> Function(String path, {int? version, OnDatabaseCreateFn? onCreate})? databaseFactory,
  }) : _databaseFactory = databaseFactory;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (_databaseFactory != null) {
      return _databaseFactory!(
        'youtube_helper.db',
        version: 1,
        onCreate: _createDb,
      );
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'youtube_helper.db');
    return openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE video_summaries (
        video_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        thumbnail_url TEXT NOT NULL,
        duration TEXT NOT NULL DEFAULT '',
        transcript TEXT NOT NULL DEFAULT '',
        summary TEXT NOT NULL,
        key_points TEXT NOT NULL DEFAULT '[]',
        transcript_preview TEXT NOT NULL DEFAULT '',
        language TEXT NOT NULL DEFAULT 'ko',
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveSummary(VideoSummary summary) async {
    final db = await database;
    await db.insert(
      'video_summaries',
      summary.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VideoSummary>> getAllSummaries() async {
    final db = await database;
    final maps = await db.query(
      'video_summaries',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => VideoSummary.fromMap(map)).toList();
  }

  Future<VideoSummary?> getSummaryById(String videoId) async {
    final db = await database;
    final maps = await db.query(
      'video_summaries',
      where: 'video_id = ?',
      whereArgs: [videoId],
    );
    if (maps.isEmpty) return null;
    return VideoSummary.fromMap(maps.first);
  }

  Future<void> deleteSummary(String videoId) async {
    final db = await database;
    await db.delete(
      'video_summaries',
      where: 'video_id = ?',
      whereArgs: [videoId],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
