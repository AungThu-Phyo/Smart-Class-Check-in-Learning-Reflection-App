import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/attendance_record.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();
  static DatabaseFactory? _webDatabaseFactory;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final path = await _databasePath();

    if (kIsWeb) {
      _database = await _webFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await _createTables(db);
          },
        ),
      );
    } else {
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await _createTables(db);
        },
      );
    }

    return _database!;
  }

  DatabaseFactory get _webFactory {
    _webDatabaseFactory ??= createDatabaseFactoryFfiWeb(
      options: SqfliteFfiWebOptions(
        sharedWorkerUri: Uri.parse('/sqflite_sw.js'),
        sqlite3WasmUri: Uri.parse('/sqlite3.wasm'),
      ),
    );
    return _webDatabaseFactory!;
  }

  Future<String> _databasePath() async {
    if (kIsWeb) {
      return 'smart_class_attendance_web.db';
    }

    final databasesPath = await getDatabasesPath();
    return join(databasesPath, 'smart_class_attendance.db');
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE attendance_records (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        class_title TEXT NOT NULL,
        session_date TEXT NOT NULL,
        status TEXT NOT NULL,
        check_in_at TEXT,
        check_in_latitude REAL,
        check_in_longitude REAL,
        check_in_accuracy_meters REAL,
        check_in_distance_meters REAL,
        check_in_within_geofence INTEGER,
        check_in_qr_value TEXT,
        previous_topic TEXT,
        expected_topic TEXT,
        mood_before_class INTEGER,
        finish_at TEXT,
        finish_latitude REAL,
        finish_longitude REAL,
        finish_accuracy_meters REAL,
        finish_distance_meters REAL,
        finish_within_geofence INTEGER,
        finish_qr_value TEXT,
        learned_today TEXT,
        class_feedback TEXT
      )
    ''');
  }

  Future<void> saveRecord(AttendanceRecord record) async {
    final db = await database;
    await db.insert(
      'attendance_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AttendanceRecord?> fetchRecordForSession(String sessionId) async {
    final db = await database;
    final rows = await db.query(
      'attendance_records',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return AttendanceRecord.fromMap(rows.first);
  }

  Future<List<AttendanceRecord>> fetchAllRecords() async {
    final db = await database;
    final rows = await db.query(
      'attendance_records',
      orderBy: 'session_date DESC',
    );

    return rows.map(AttendanceRecord.fromMap).toList();
  }
}
