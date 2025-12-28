import 'package:flutter/foundation.dart';
import 'package:travelapp/models/checklist_model.dart';
import 'package:travelapp/repository/checklist_repository.dart';

class ChecklistViewModel extends ChangeNotifier {
  final ChecklistRepository _repository = ChecklistRepository();

  List<ChecklistItem> _items = [];
  ChecklistSummary? _summary;
  bool _isLoading = false;
  String? _error;

  List<ChecklistItem> get items => _items;
  ChecklistSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalItems => _summary?.totalItems ?? 0;
  int get completedItems => _summary?.completedItems ?? 0;
  int get progressPercent => _summary?.progress ?? 0;

  List<ChecklistItem> get completedItems_List => _items.where((item) => item.completed).toList();
  List<ChecklistItem> get pendingItems => _items.where((item) => !item.completed).toList();

  Future<void> fetchChecklistItems(int tripId) async {
    _setLoading(true);
    try {
      final items = await _repository.getChecklistItems(tripId);
      final summary = await _repository.getChecklistSummary(tripId);
      _items = items;
      _summary = summary;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addChecklistItem(int tripId, String title, {String? description, int? assignedUserId}) async {
    _setLoading(true);
    try {
      final data = {
        'title': title,
        'description': description,
        'assignedToUserId': assignedUserId,
      };
      final newItem = await _repository.createChecklistItem(tripId, data);
      _items.add(newItem);
      await _refreshSummary(tripId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleChecklistItem(int tripId, int itemId) async {
    try {
      final updatedItem = await _repository.toggleChecklistItem(tripId, itemId);
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        _items[index] = updatedItem;
      }
      await _refreshSummary(tripId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteChecklistItem(int tripId, int itemId) async {
    try {
      await _repository.deleteChecklistItem(tripId, itemId);
      _items.removeWhere((item) => item.id == itemId);
      await _refreshSummary(tripId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> updateChecklistItem(int tripId, int itemId, String title, {String? description, int? assignedUserId}) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'assignedToUserId': assignedUserId,
      };
      final updatedItem = await _repository.updateChecklistItem(tripId, itemId, data);
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        _items[index] = updatedItem;
      }
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> _refreshSummary(int tripId) async {
    try {
      _summary = await _repository.getChecklistSummary(tripId);
    } catch (e) {
      // Silent fail for summary refresh
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
