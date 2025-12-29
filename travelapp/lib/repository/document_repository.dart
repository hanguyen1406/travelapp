import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../utils/app_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show SocketException;
import 'package:shared_preferences/shared_preferences.dart';

class Document {
  final int id;
  final String name; // Document name
  final String category;
  final DateTime createdAt;
  final bool isImportant;
  final String? url; // File URL
  final String? originalFileName;
  final String? fileSize;
  final String? type; // MIME type
  final bool? offlineAvailable;
  final int? tripId;
  final int? uploadedBy;

  Document({
    required this.id,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.isImportant,
    this.url,
    this.originalFileName,
    this.fileSize,
    this.type,
    this.offlineAvailable,
    this.tripId,
    this.uploadedBy,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    print('📝 [Document.fromJson] Parsing: $json');

    // Parse createdAt with error handling
    DateTime parsedDate = DateTime.now();
    try {
      if (json['createdAt'] != null) {
        final createdAt = json['createdAt'];
        if (createdAt is int) {
          parsedDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
        } else {
          parsedDate = DateTime.parse(createdAt.toString());
        }
      }
    } catch (e) {
      print('⚠️ Error parsing date: ${json['createdAt']} - $e');
    }

    // Parse numeric fields safely
    int? tripId;
    try {
      if (json['tripId'] != null) {
        tripId = int.tryParse(json['tripId'].toString());
      }
    } catch (e) {
      print('⚠️ Error parsing tripId: ${json['tripId']} - $e');
    }

    int? uploadedBy;
    try {
      if (json['uploadedById'] != null) {
        uploadedBy = int.tryParse(json['uploadedById'].toString());
      } else if (json['uploadedBy'] != null) {
        // Fallback for compatibility
        uploadedBy = int.tryParse(json['uploadedBy'].toString());
      }
    } catch (e) {
      print('⚠️ Error parsing uploadedBy: ${json['uploadedById'] ?? json['uploadedBy']} - $e');
    }

    return Document(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      createdAt: parsedDate,
      isImportant: (json['isImportant'] as bool?) ?? false,
      url: json['url']?.toString(),
      originalFileName: json['originalFileName']?.toString(),
      fileSize: json['fileSize']?.toString(),
      type: json['type']?.toString(),
      offlineAvailable: (json['offlineAvailable'] as bool?) ?? false,
      tripId: tripId,
      uploadedBy: uploadedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isImportant': isImportant,
      'url': url,
      'originalFileName': originalFileName,
      'fileSize': fileSize,
      'type': type,
      'offlineAvailable': offlineAvailable,
      'tripId': tripId,
      'uploadedBy': uploadedBy,
    };
  }
}

class DocumentRepository {
  static String get baseUrl => AppConfig.baseUrl;

  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Upload document with file
  static Future<Document> uploadDocument({
    required int tripId,
    required String title,
    required String category,
    required bool isImportant,
    required XFile file,
  }) async {
    try {
      final uploadUrl = Uri.parse('$baseUrl/documents/upload');

      print('📡 [REPO] POST to: $uploadUrl');

      var request = http.MultipartRequest('POST', uploadUrl);
      final headers = await _getAuthHeaders();
      request.headers.addAll(headers);

      request.fields['tripId'] = tripId.toString();
      request.fields['title'] = title;
      request.fields['category'] = category;
      request.fields['isImportant'] = isImportant.toString();

      // Read file as bytes first
      var fileBytes = await file.readAsBytes();
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: file.name,
      );
      request.files.add(multipartFile);

      print('📡 [REPO] Sending request... Fields: ${request.fields}');

      var response = await request
          .send()
          .timeout(const Duration(seconds: 60))
          .catchError((e) {
            print('❌ [REPO] Request failed: $e');
            throw Exception('Network error: $e');
          });

      print('📡 [REPO] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        print('✅ [REPO] Response body: $responseBody');
        final jsonResponse = json.decode(responseBody);
        return Document.fromJson(jsonResponse);
      } else {
        final errorBody = await response.stream.bytesToString();
        print('❌ [REPO] Error: ${response.statusCode} - $errorBody');
        throw Exception('Upload failed: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ [REPO] Exception: $e');
      throw Exception('Upload error: $e');
    }
  }

  // Get all documents for a trip
  static Future<List<Document>> getDocuments(int tripId) async {
    try {
      final url = Uri.parse('$baseUrl/documents/trip?tripId=$tripId');
      print('📡 [REPO] GET from: $url');

      final headers = await _getAuthHeaders();
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📡 [REPO] Response status: ${response.statusCode}');
      print('📡 [REPO] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('✅ [REPO] Parsed ${jsonData.length} documents');

        final List<Document> documents = [];
        for (var doc in jsonData) {
          try {
            documents.add(Document.fromJson(doc as Map<String, dynamic>));
          } catch (e) {
            print('❌ [REPO] Error parsing document: $doc - $e');
          }
        }

        print('✅ [REPO] Successfully converted ${documents.length} documents');
        return documents;
      } else {
        print('❌ [REPO] Error status: ${response.statusCode}');
        throw Exception(
          'Failed to load documents: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ [REPO] Exception: $e');
      throw Exception('Error fetching documents: $e');
    }
  }

  // Delete document
  static Future<void> deleteDocument(int documentId) async {
    try {
      final url = Uri.parse('$baseUrl/documents/$documentId');
      print('📡 [REPO] DELETE from: $url');

      final headers = await _getAuthHeaders();
      final response = await http
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📡 [REPO] Delete response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete document: ${response.statusCode} - ${response.body}',
        );
      }

      print('✅ [REPO] Document deleted successfully');
    } catch (e) {
      print('❌ [REPO] Error deleting document: $e');
      throw Exception('Error deleting document: $e');
    }
  }

  // Mark document as important
  static Future<Document> toggleImportant(
    int documentId,
    bool isImportant,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/documents/$documentId/important');
      final body = json.encode({'isImportant': isImportant});

      print('📡 [REPO] PATCH to: $url');
      print('📡 [REPO] Body: $body');

      final headers = await _getAuthHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http
          .patch(
            url,
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      print('📡 [REPO] Response status: ${response.statusCode}');
      print('📡 [REPO] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final document = Document.fromJson(json.decode(response.body));
        print('✅ [REPO] Document importance updated');
        return document;
      } else {
        throw Exception(
          'Failed to update document: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ [REPO] Error updating document: $e');
      throw Exception('Error updating document: $e');
    }
  }

  // Get documents by category
  static Future<List<Document>> getDocumentsByCategory(
    int tripId,
    String category,
  ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/documents/category?tripId=$tripId&category=$category',
      );
      print('📡 [REPO] GET from: $url');

      final headers = await _getAuthHeaders();
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📡 [REPO] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((doc) => Document.fromJson(doc)).toList();
      } else {
        throw Exception(
          'Failed to load documents: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ [REPO] Error fetching documents by category: $e');
      throw Exception('Error fetching documents by category: $e');
    }
  }
}
