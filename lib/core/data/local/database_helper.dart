import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _databaseName = 'vouch_local.db';
  static const int _databaseVersion = 1;
  static const String _studentsTable = 'Students';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
			CREATE TABLE IF NOT EXISTS Students (
				student_id TEXT PRIMARY KEY,
				full_name TEXT NOT NULL,
				faculty TEXT NOT NULL,
				program TEXT NOT NULL,
				email TEXT NOT NULL UNIQUE,
				password_hash TEXT NOT NULL,
				profile_photo_url TEXT NOT NULL,
				account_status TEXT DEFAULT 'active',
				created_at TEXT NOT NULL
			);
		''');
  }

  Future<void> insertStudent({
    required String studentId,
    required String fullName,
    required String faculty,
    required String program,
    required String email,
    required String rawPassword,
  }) async {
    final db = await database;

    final passwordHash = sha256.convert(utf8.encode(rawPassword)).toString();

    await db.insert(_studentsTable, {
      'student_id': studentId,
      'full_name': fullName,
      'faculty': faculty,
      'program': program,
      'email': email,
      'password_hash': passwordHash,
      'profile_photo_url': '',
      'account_status': 'active',
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getStudentByEmail(String email) async {
    final db = await database;

    final rows = await db.query(
      _studentsTable,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    final db = await database;
    return db.query(_studentsTable, orderBy: 'created_at DESC');
  }
}
