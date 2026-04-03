import '../models/sleep_plan.dart';
import '../models/sleep_block.dart';

/// Abstract repository for sleep plan operations.
abstract class SleepRepository {
  Future<List<SleepPlan>> getAllPlans();
  Future<List<SleepPlan>> getPlansInRange(DateTime start, DateTime end);
  Future<SleepPlan?> getPlanById(String id);
  Future<SleepPlan?> getPlanForDate(DateTime date);
  Future<void> insertPlan(SleepPlan plan);
  Future<void> updatePlan(SleepPlan plan);
  Future<void> deletePlan(String id);
  Future<void> deleteAllPlans();
  Future<void> insertSleepBlock(String planId, SleepBlock block);
  Future<void> updateSleepBlock(SleepBlock block);
  Future<void> deleteSleepBlock(String id);
}
