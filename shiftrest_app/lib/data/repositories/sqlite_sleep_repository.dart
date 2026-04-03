import '../../domain/models/sleep_plan.dart';
import '../../domain/models/sleep_block.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../database/app_database.dart';

/// SQLite implementation of SleepRepository.
class SqliteSleepRepository implements SleepRepository {
  @override
  Future<List<SleepPlan>> getAllPlans() async {
    final db = await AppDatabase.database;
    final planMaps = await db.query('sleep_plans', orderBy: 'date DESC');

    final plans = <SleepPlan>[];
    for (final planMap in planMaps) {
      final blocks = await _getBlocksForPlan(planMap['id'] as String);
      plans.add(SleepPlan.fromMap(planMap, blocks));
    }
    return plans;
  }

  @override
  Future<List<SleepPlan>> getPlansInRange(DateTime start, DateTime end) async {
    final db = await AppDatabase.database;
    final planMaps = await db.query(
      'sleep_plans',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );

    final plans = <SleepPlan>[];
    for (final planMap in planMaps) {
      final blocks = await _getBlocksForPlan(planMap['id'] as String);
      plans.add(SleepPlan.fromMap(planMap, blocks));
    }
    return plans;
  }

  @override
  Future<SleepPlan?> getPlanById(String id) async {
    final db = await AppDatabase.database;
    final maps = await db.query('sleep_plans', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    final blocks = await _getBlocksForPlan(id);
    return SleepPlan.fromMap(maps.first, blocks);
  }

  @override
  Future<SleepPlan?> getPlanForDate(DateTime date) async {
    final db = await AppDatabase.database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    final maps = await db.query(
      'sleep_plans',
      where: 'date LIKE ?',
      whereArgs: ['${dateStr.substring(0, 10)}%'],
    );
    if (maps.isEmpty) return null;
    final blocks = await _getBlocksForPlan(maps.first['id'] as String);
    return SleepPlan.fromMap(maps.first, blocks);
  }

  @override
  Future<void> insertPlan(SleepPlan plan) async {
    final db = await AppDatabase.database;
    await db.insert('sleep_plans', plan.toMap());

    for (final block in plan.sleepBlocks) {
      await db.insert('sleep_blocks', {
        ...block.toMap(),
        'planId': plan.id,
      });
    }
  }

  @override
  Future<void> updatePlan(SleepPlan plan) async {
    final db = await AppDatabase.database;
    await db.update(
      'sleep_plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );

    // Delete old blocks and re-insert
    await db.delete('sleep_blocks', where: 'planId = ?', whereArgs: [plan.id]);
    for (final block in plan.sleepBlocks) {
      await db.insert('sleep_blocks', {
        ...block.toMap(),
        'planId': plan.id,
      });
    }
  }

  @override
  Future<void> deletePlan(String id) async {
    final db = await AppDatabase.database;
    await db.delete('sleep_blocks', where: 'planId = ?', whereArgs: [id]);
    await db.delete('sleep_plans', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAllPlans() async {
    final db = await AppDatabase.database;
    await db.delete('sleep_blocks');
    await db.delete('sleep_plans');
  }

  @override
  Future<void> insertSleepBlock(String planId, SleepBlock block) async {
    final db = await AppDatabase.database;
    await db.insert('sleep_blocks', {
      ...block.toMap(),
      'planId': planId,
    });
  }

  @override
  Future<void> updateSleepBlock(SleepBlock block) async {
    final db = await AppDatabase.database;
    await db.update(
      'sleep_blocks',
      block.toMap(),
      where: 'id = ?',
      whereArgs: [block.id],
    );
  }

  @override
  Future<void> deleteSleepBlock(String id) async {
    final db = await AppDatabase.database;
    await db.delete('sleep_blocks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SleepBlock>> _getBlocksForPlan(String planId) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      'sleep_blocks',
      where: 'planId = ?',
      whereArgs: [planId],
      orderBy: 'startTime ASC',
    );
    return maps.map((m) => SleepBlock.fromMap(m)).toList();
  }
}
