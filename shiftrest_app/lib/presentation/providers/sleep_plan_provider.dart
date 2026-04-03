import 'package:flutter/foundation.dart';
import '../../domain/models/shift.dart';
import '../../domain/models/sleep_plan.dart';
import '../../domain/models/sleep_block.dart';
import '../../domain/services/sleep_calculator.dart';
import '../../domain/repositories/sleep_repository.dart';

/// State management for sleep plans.
class SleepPlanProvider extends ChangeNotifier {
  final SleepRepository _repository;
  final SleepCalculator _calculator;

  List<SleepPlan> _plans = [];
  SleepPlan? _currentPlan;
  bool _isLoading = false;
  String? _error;

  SleepPlanProvider(this._repository, this._calculator);

  List<SleepPlan> get plans => _plans;
  SleepPlan? get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Calculate sleep plans for a list of shifts.
  void calculatePlans(List<Shift> shifts) {
    if (shifts.isEmpty) {
      _plans = [];
      _currentPlan = null;
      notifyListeners();
      return;
    }

    _plans = _calculator.calculatePlansForSchedule(shifts);
    _currentPlan = _plans.isNotEmpty ? _plans.first : null;
    notifyListeners();
  }

  /// Calculate plan for the next shift.
  void calculateNextPlan({Shift? currentShift, required Shift nextShift}) {
    _currentPlan = _calculator.calculateSleepPlan(
      currentShift: currentShift,
      nextShift: nextShift,
      date: nextShift.date,
    );
    notifyListeners();
  }

  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();

    try {
      _plans = await _repository.getAllPlans();
      if (_plans.isNotEmpty) {
        _currentPlan = _plans.first;
      }
    } catch (e) {
      _error = 'Failed to load plans: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> savePlan(SleepPlan plan) async {
    try {
      await _repository.insertPlan(plan);
      _plans.insert(0, plan);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save plan: $e';
      notifyListeners();
    }
  }

  Future<void> logActualSleep(String planId, SleepBlock actualBlock) async {
    try {
      final block = actualBlock.copyWith(isPlanned: false);
      await _repository.insertSleepBlock(planId, block);

      final planIndex = _plans.indexWhere((p) => p.id == planId);
      if (planIndex >= 0) {
        final plan = _plans[planIndex];
        _plans[planIndex] = plan.copyWith(
          sleepBlocks: [...plan.sleepBlocks, block],
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to log sleep: $e';
      notifyListeners();
    }
  }

  Future<void> deleteAllPlans() async {
    try {
      await _repository.deleteAllPlans();
      _plans.clear();
      _currentPlan = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete plans: $e';
      notifyListeners();
    }
  }
}
