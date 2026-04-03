import '../models/shift.dart';

/// Abstract repository for shift operations.
abstract class ShiftRepository {
  Future<List<Shift>> getAllShifts();
  Future<List<Shift>> getShiftsInRange(DateTime start, DateTime end);
  Future<Shift?> getShiftById(String id);
  Future<void> insertShift(Shift shift);
  Future<void> updateShift(Shift shift);
  Future<void> deleteShift(String id);
  Future<void> deleteAllShifts();
}
