import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants.dart';
import '../models/video_summary.dart';

class DatabaseHelper {
  static Database? _database;
  final Future<Database> Function()? databaseFactory;

  DatabaseHelper({this.databaseFactory});

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (databaseFactory != null) {
      return databaseFactory!();
    }
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE summaries(
        video_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        thumbnail_url TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        summary TEXT NOT NULL,
        key_points TEXT NOT NULL,
        transcript_text TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertSummary(VideoSummary summary) async {
    final db = await database;
    await db.insert(
      'summaries',
      summary.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VideoSummary>> getAllSummaries() async {
    final db = await database;
    final maps = await db.query(
      'summaries',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => VideoSummary.fromDbMap(map)).toList();
  }

  Future<VideoSummary?> getSummaryById(String videoId) async {
    final db = await database;
    final maps = await db.query(
      'summaries',
      where: 'video_id = ?',
      whereArgs: [videoId],
    );
    if (maps.isEmpty) return null;
    return VideoSummary.fromDbMap(maps.first);
  }

  Future<void> deleteSummary(String videoId) async {
    final db = await database;
    await db.delete(
      'summaries',
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
