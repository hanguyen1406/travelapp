import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/models/checklist_model.dart';
import 'package:travelapp/data/network/base_api_services.dart';
import 'package:travelapp/data/network/network_api_services.dart';
import 'package:travelapp/utils/app_config.dart';

class ChecklistRepository {
  final BaseApiServices _apiServices = NetworkApiServices();
  // Demo mode - set to true to use mock data instead of API
  final bool _useMockData = true;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Mock data generators
  List<ChecklistItem> _getMockChecklistItems(int tripId) {
    return [
      ChecklistItem(
        id: 1,
        tripId: tripId,
        title: 'Hộ chiếu và giấy tờ',
        description: 'Chuẩn bị hộ chiếu, vé máy bay, visa',
        completed: true,
        assignedToUserId: 1,
        assignedToUserName: 'Sarah',
        assignedToUserAvatar: null,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ChecklistItem(
        id: 2,
        tripId: tripId,
        title: 'Sách hướng dẫn du lịch',
        description: 'Tìm kiếm và in các sách hướng dẫn du lịch',
        completed: false,
        assignedToUserId: 2,
        assignedToUserName: 'Mia',
        assignedToUserAvatar: null,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: null,
      ),
      ChecklistItem(
        id: 3,
        tripId: tripId,
        title: 'Quần áo và giày',
        description: 'Chuẩn bị quần áo phù hợp với thời tiết',
        completed: false,
        assignedToUserId: 3,
        assignedToUserName: 'Lia',
        assignedToUserAvatar: null,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: null,
      ),
      ChecklistItem(
        id: 4,
        tripId: tripId,
        title: 'Máy ảnh và pin',
        description: 'Sạc pin máy ảnh, chuẩn bị dung lượng thẻ nhớ',
        completed: true,
        assignedToUserId: null,
        assignedToUserName: null,
        assignedToUserAvatar: null,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      ),
      ChecklistItem(
        id: 5,
        tripId: tripId,
        title: 'Thuốc và mỹ phẩm',
        description: 'Thuốc cảm, kem chống nắng, kem dưỡng ẩm',
        completed: false,
        assignedToUserId: 1,
        assignedToUserName: 'Sarah',
        assignedToUserAvatar: null,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: null,
      ),
    ];
  }

  ChecklistSummary _getMockChecklistSummary(int tripId, List<ChecklistItem> items) {
    final completed = items.where((item) => item.completed).length;
    return ChecklistSummary(
      totalItems: items.length,
      completedItems: completed,
      tripId: tripId,
    );
  }

  Future<ChecklistSummary> getChecklistSummary(int tripId) async {
    try {
      if (_useMockData) {
        // Return mock data
        await Future.delayed(const Duration(milliseconds: 500));
        final items = _getMockChecklistItems(tripId);
        return _getMockChecklistSummary(tripId, items);
      }

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      dynamic response = await _apiServices.getGetApiResponseWithToken(
        '${AppConfig.baseUrl}/trips/$tripId/checklist/summary',
        token,
      );
      return ChecklistSummary.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChecklistItem>> getChecklistItems(int tripId) async {
    try {
      if (_useMockData) {
        // Return mock data
        await Future.delayed(const Duration(milliseconds: 500));
        return _getMockChecklistItems(tripId);
      }

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      dynamic response = await _apiServices.getGetApiResponseWithToken(
        '${AppConfig.baseUrl}/trips/$tripId/checklist',
        token,
      );
      if (response is List) {
        return response.map((item) => ChecklistItem.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<ChecklistItem> createChecklistItem(int tripId, Map<String, dynamic> data) async {
    try {
      if (_useMockData) {
        // Return mock data
        await Future.delayed(const Duration(milliseconds: 300));
        final items = _getMockChecklistItems(tripId);
        final maxId = items.isNotEmpty ? items.map((e) => e.id).reduce((a, b) => a > b ? a : b) : 0;
        return ChecklistItem(
          id: maxId + 1,
          tripId: tripId,
          title: data['title'] ?? 'New Item',
          description: data['description'],
          completed: false,
          assignedToUserId: data['assignedToUserId'],
          assignedToUserName: data['assignedToUserName'],
          createdAt: DateTime.now(),
        );
      }

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      dynamic response = await _apiServices.getPostApiResponseWithToken(
        '${AppConfig.baseUrl}/trips/$tripId/checklist',
        data,
        token,
      );
      return ChecklistItem.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ChecklistItem> updateChecklistItem(int tripId, int itemId, Map<String, dynamic> data) async {
    try {
      if (_useMockData) {
        // Return mock data
        await Future.delayed(const Duration(milliseconds: 300));
        return ChecklistItem(
          id: itemId,
          tripId: tripId,
          title: data['title'] ?? 'Updated Item',
          description: data['description'],
          completed: false,
          assignedToUserId: data['assignedToUserId'],
          assignedToUserName: data['assignedToUserName'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      dynamic response = await _apiServices.getPostApiResponseWithToken(
        '${AppConfig.baseUrl}/trips/$tripId/checklist/$itemId',
        data,
        token,
      );
      return ChecklistItem.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteChecklistItem(int tripId, int itemId) async {
    try {
      if (_useMockData) {
        // Simulate deletion
        await Future.delayed(const Duration(milliseconds: 300));
        return true;
      }

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      await _apiServices.getPostApiResponseWithToken(
        '${AppConfig.baseUrl}/trips/$tripId/checklist/$itemId/delete',
        {},
        token,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<ChecklistItem> toggleChecklistItem(int tripId, int itemId) async {
    try {
      if (_useMockData) {
        // Simulate toggle
        await Future.delayed(const Duration(milliseconds: 300));
        final items = _getMockChecklistItems(tripId);
        final item = items.firstWhere((item) => item.id == itemId, orElse: () => items.first);
        return ChecklistItem(
          id: item.id,
          tripId: item.tripId,
          title: item.title,
          description: item.description,
          completed: !item.completed,
          assignedToUserId: item.assignedToUserId,
          assignedToUserName: item.assignedToUserName,
          createdAt: item.createdAt,
          updatedAt: DateTime.now(),
        );
      }

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      dynamic response = await _apiServices.getPostApiResponseWithToken(
        '${AppConfig.baseUrl}/trips/$tripId/checklist/$itemId/toggle',
        {},
        token,
      );
      return ChecklistItem.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
