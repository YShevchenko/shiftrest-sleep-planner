import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants.dart';

/// SQLite database manager.
class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE shifts (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        type TEXT NOT NULL,
        commuteMinutes INTEGER DEFAULT 30,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sleep_plans (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        shiftId TEXT,
        strategy TEXT NOT NULL,
        sleepDebtHours REAL,
        recommendation TEXT,
        FOREIGN KEY (shiftId) REFERENCES shifts(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sleep_blocks (
        id TEXT PRIMARY KEY,
        planId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        type TEXT NOT NULL,
        isPlanned INTEGER DEFAULT 1,
        qualityRating INTEGER,
        tags TEXT,
        FOREIGN KEY (planId) REFERENCES sleep_plans(id) ON DELETE CASCADE
      )
    ''');

    // Indexes
    await db.execute('CREATE INDEX idx_shifts_date ON shifts(date)');
    await db.execute('CREATE INDEX idx_plans_date ON sleep_plans(date)');
    await db.execute('CREATE INDEX idx_blocks_plan ON sleep_blocks(planId)');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add tags column to sleep_blocks (migration from v1)
      await db.execute(
        'ALTER TABLE sleep_blocks ADD COLUMN tags TEXT',
      );
    }
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  static Future<void> deleteDatabase_() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    await deleteDatabase(path);
    _database = null;
  }
}
