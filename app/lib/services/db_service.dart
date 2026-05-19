import 'package:sqflite/sqflite.dart';
import '../models/soil_reading.dart';

class DbService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await openDatabase(
      '${await getDatabasesPath()}/soil.db',
      version: 1,
      onCreate: (db, v) => db.execute('''
        CREATE TABLE readings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT, moisture REAL, temperature REAL,
          ec REAL, ph REAL, nitrogen REAL, phosphorus REAL, potassium REAL, salinity REAL
        )
      '''),
    );
    return _db!;
  }

  static Future<void> insert(SoilReading r) async {
    final d = await db;
    await d.insert('readings', r.toMap());
  }

  static Future<List<SoilReading>> getAll({int limit = 500}) async {
    final d = await db;
    final rows = await d.query('readings', orderBy: 'id DESC', limit: limit);
    return rows.map((r) => SoilReading.fromMap(r)).toList();
  }
}
