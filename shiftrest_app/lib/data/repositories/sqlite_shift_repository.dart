import '../../domain/models/shift.dart';
import '../../domain/repositories/shift_repository.dart';
import '../database/app_database.dart';

/// SQLite implementation of ShiftRepository.
class SqliteShiftRepository implements ShiftRepository {
  @override
  Future<List<Shift>> getAllShifts() async {
    final db = await AppDatabase.database;
    final maps = await db.query('shifts', orderBy: 'startTime ASC');
    return maps.map((m) => Shift.fromMap(m)).toList();
  }

  @override
  Future<List<Shift>> getShiftsInRange(DateTime start, DateTime end) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      'shifts',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'startTime ASC',
    );
    return maps.map((m) => Shift.fromMap(m)).toList();
  }

  @override
  Future<Shift?> getShiftById(String id) async {
    final db = await AppDatabase.database;
    final maps = await db.query('shifts', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Shift.fromMap(maps.first);
  }

  @override
  Future<void> insertShift(Shift shift) async {
    final db = await AppDatabase.database;
    await db.insert('shifts', shift.toMap());
  }

  @override
  Future<void> updateShift(Shift shift) async {
    final db = await AppDatabase.database;
    await db.update(
      'shifts',
      shift.toMap(),
      where: 'id = ?',
      whereArgs: [shift.id],
    );
  }

  @override
  Future<void> deleteShift(String id) async {
    final db = await AppDatabase.database;
    await db.delete('shifts', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAllShifts() async {
    final db = await AppDatabase.database;
    await db.delete('shifts');
  }
}
