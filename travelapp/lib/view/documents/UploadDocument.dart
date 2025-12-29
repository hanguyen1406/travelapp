import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../repository/document_repository.dart';

// Removed conditional import to use platform-agnostic XFile
import 'dart:io' show SocketException;

class UploadDocumentScreen extends StatefulWidget {
  final int tripId;
  const UploadDocumentScreen({Key? key, required this.tripId})
    : super(key: key);

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final TextEditingController _titleController = TextEditingController();
  String selectedCategory = 'Chuyến bay';
  bool isImportant = false;
  XFile? pickedFile;
  bool isLoading = false;

  final List<String> categories = [
    'Chuyến bay',
    'Khách sạn',
    'Bảo hiểm',
    'ID/Visa',
  ];

  final Map<String, IconData> categoryIcons = {
    'Chuyến bay': Icons.flight,
    'Khách sạn': Icons.hotel,
    'Bảo hiểm': Icons.verified_user,
    'ID/Visa': Icons.credit_card,
  };

  final Map<String, Color> categoryColors = {
    'Chuyến bay': const Color(0xFF4D96FF),
    'Khách sạn': const Color(0xFFFFC107),
    'Bảo hiểm': const Color(0xFF4ECDC4),
    'ID/Visa': const Color(0xFFF06292),
  };

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source);
      if (file != null) {
        setState(() {
          pickedFile = file;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi chọn file: $e');
    }
  }

  Future<void> _uploadDocument() async {
    print('🔵 [UPLOAD] Button pressed!');

    // Validation
    if (_titleController.text.trim().isEmpty) {
      print('⚠️ Title is empty');
      _showErrorSnackBar('Vui lòng nhập tên tài liệu');
      return;
    }

    if (pickedFile == null) {
      print('⚠️ No file selected');
      _showErrorSnackBar('Vui lòng chọn file hoặc chụp ảnh');
      return;
    }

    // Check file size (max 50MB)
    final fileSize = await pickedFile!.length();
    if (fileSize > 52428800) {
      print('⚠️ File too large: ${fileSize}');
      _showErrorSnackBar('File vượt quá 50MB. Vui lòng chọn file nhỏ hơn.');
      return;
    }

    print('✅ Validation passed. Setting loading state...');
    setState(() => isLoading = true);

    try {
      // Platform-agnostic XFile is used instead of io.File

      print('📤 [UPLOAD] Bắt đầu tải lên:');
      print('   - TripID: ${widget.tripId}');
      print('   - Title: ${_titleController.text.trim()}');
      print('   - Category: $selectedCategory');
      print('   - File: ${pickedFile!.name}');
      print('   - Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      print('   - Server: ${DocumentRepository.baseUrl}');

      print('📞 Calling DocumentRepository.uploadDocument...');
      final newDoc = await DocumentRepository.uploadDocument(
        tripId: widget.tripId,
        title: _titleController.text.trim(),
        category: selectedCategory,
        isImportant: isImportant,
        file: pickedFile!,
      );

      print('✅ [UPLOAD] Thành công! ID: ${newDoc.id}');

      if (!mounted) {
        print('⚠️ Widget not mounted after upload');
        return;
      }

      _showSuccessSnackBar('Tải tài liệu lên thành công!');
      Navigator.pop(context, newDoc);
    } catch (e) {
      if (!kIsWeb && e is SocketException) {
        print('❌ [UPLOAD] Lỗi kết nối: $e');
        _showErrorSnackBar(
          'Không thể kết nối đến server.\n\n'
          'Kiểm tra:\n'
          '1. Backend đang chạy không? (port 8080)\n'
          '2. WiFi/Internet kết nối?\n'
          '3. URL config: ${DocumentRepository.baseUrl}',
        );
      } else if (e is TimeoutException) {
        print('❌ [UPLOAD] Timeout: $e');
        _showErrorSnackBar('Upload quá lâu. Kiểm tra kết nối mạng.');
      } else {
        print('❌ [UPLOAD] Lỗi: $e');
        _showErrorSnackBar('Lỗi tải lên: $e');
      }
    } finally {
      print('🔄 Finally block - setting loading to false');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm tài liệu',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải lên...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upload Method Section
                  _buildUploadMethodSection(),
                  const SizedBox(height: 24),

                  // Title Input Section
                  _buildTitleSection(),
                  const SizedBox(height: 24),

                  // Category Section
                  _buildCategorySection(),
                  const SizedBox(height: 24),

                  // Important Checkbox Section
                  _buildImportantSection(),
                  const SizedBox(height: 16),

                  // Upload Button
                  _buildUploadButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildUploadMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn phương thức tải lên',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickFile(ImageSource.gallery),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.upload_file, color: Colors.grey, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Upload File',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _pickFile(ImageSource.camera),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.camera_alt, color: Colors.grey, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Take Photo',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (pickedFile != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File đã chọn',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        pickedFile!.name,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tên tài liệu',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          onChanged: (value) {
            print('📝 Title changed: $value');
            setState(() {}); // Update parent state
          },
          decoration: InputDecoration(
            hintText: 'Ví dụ: Vé máy bay - Garuda Indonesia',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: _titleController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      print('📝 Title cleared');
                      _titleController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thể loại',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => selectedCategory = category),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? categoryColors[category] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      categoryIcons[category],
                      size: 32,
                      color: isSelected
                          ? Colors.white
                          : categoryColors[category],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImportantSection() {
    return GestureDetector(
      onTap: () => setState(() => isImportant = !isImportant),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              isImportant ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isImportant ? const Color(0xFF0066FF) : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đánh dấu là quan trọng',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Truy cập nhanh vào các tài liệu cần thiết',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    final titleEmpty = _titleController.text.trim().isEmpty;
    final noFile = pickedFile == null;
    final isEnabled = !titleEmpty && !noFile;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (isEnabled && !isLoading)
                ? () {
                    print(
                      '🔘 Button onPressed called! isLoading=$isLoading, isEnabled=$isEnabled',
                    );
                    _uploadDocument();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? const Color(0xFF0066FF)
                  : Colors.grey[300],
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Đang tải lên...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Tải tài liệu lên',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isEnabled ? Colors.white : Colors.grey[400],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        if (!isEnabled)
          Text(
            titleEmpty ? '⚠️ Nhập tên tài liệu' : '⚠️ Chọn file trước',
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
      ],
    );
  }

}
