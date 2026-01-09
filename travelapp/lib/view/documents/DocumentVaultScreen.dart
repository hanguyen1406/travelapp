import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'UploadDocument.dart';
import 'DocumentViewer.dart';
import '../../repository/document_repository.dart';

class DocumentVaultScreen extends StatefulWidget {
  final int tripId;
  const DocumentVaultScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends State<DocumentVaultScreen> {
  List<Document> documents = [];
  List<Document> importantDocs = [];
  List<Document> filteredDocs = [];
  String selectedCategory = 'Tất cả';
  bool isLoading = false;
  final List<String> categories = [
    'Tất cả',
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
    'Chuyến bay': Color(0xFF4D96FF),
    'Khách sạn': Color(0xFFFFC107),
    'Bảo hiểm': Color(0xFF4ECDC4),
    'ID/Visa': Color(0xFFF06292),
  };

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() async {
    setState(() => isLoading = true);
    try {
      print('📂 [VAULT] Loading documents for tripId: ${widget.tripId}');
      print('📂 [VAULT] API Base URL: ${DocumentRepository.baseUrl}');

      final loadedDocs = await DocumentRepository.getDocuments(widget.tripId);
      print('✅ [VAULT] Loaded ${loadedDocs.length} documents from API');

      setState(() {
        documents = loadedDocs;
        importantDocs = documents.where((d) => d.isImportant).toList();
        _filterDocs();
        isLoading = false;
      });
    } catch (e) {
      print('❌ [VAULT] Error loading documents: $e');
      print('❌ [VAULT] Stack trace: ${StackTrace.current}');

      setState(() {
        isLoading = false;
        // Ensure lists are empty on error so no stale/fake data is shown
        documents = [];
        importantDocs = [];
        filteredDocs = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải tài liệu: $e')),
      );
    }
  }

  void _filterDocs() {
    if (selectedCategory == 'Tất cả') {
      filteredDocs = documents;
    } else {
      filteredDocs = documents
          .where((d) => d.category == selectedCategory)
          .toList();
    }
    setState(() {});
  }

  void _onCategoryChanged(String category) {
    setState(() => selectedCategory = category);
    _filterDocs();
  }

  void _addDocument() async {
    // Navigate to upload document screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadDocumentScreen(tripId: widget.tripId),
      ),
    );

    // If a document was added, refresh the list
    if (result != null && result is Document) {
      setState(() {
        documents.add(result);
        if (result.isImportant) {
          importantDocs.add(result);
        }
        _filterDocs();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm: ${result.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
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
          'Tài liệu',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF0066FF)),
            onPressed: _addDocument,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  _buildSearchBar(),
                  const SizedBox(height: 8),
                  // Safe doc count
                  _buildSafeDocCount(),
                  const SizedBox(height: 8),
                  // Category filter
                  _buildCategoryTabs(),
                  const SizedBox(height: 8),
                  // Important docs
                  if (importantDocs.isNotEmpty) ...[
                    _buildImportantHeader(),
                    _buildImportantList(),
                  ],
                  // All docs
                  _buildAllDocsHeader(),
                  _buildAllDocsList(),
                  const SizedBox(height: 16),
                  // Add doc button
                  _buildAddDocButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm tài liệu...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          // TODO: Implement search
        },
      ),
    );
  }

  Widget _buildSafeDocCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.folder, color: Color(0xFF0066FF)),
            const SizedBox(width: 8),
            Text(
              '${documents.length} tài liệu được lưu trữ an toàn',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                onSelected: (value) => _onCategoryChanged(category),
                label: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                backgroundColor: isSelected
                    ? const Color(0xFF0066FF)
                    : Colors.grey[200],
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildImportantHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
          SizedBox(width: 6),
          Text('Quan trọng', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildImportantList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: importantDocs
            .map((doc) => _buildDocumentCard(doc, isImportant: true))
            .toList(),
      ),
    );
  }

  Widget _buildAllDocsHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        'Tất cả tài liệu',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAllDocsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: filteredDocs.map((doc) => _buildDocumentCard(doc)).toList(),
      ),
    );
  }

  Widget _buildDocumentCard(Document doc, {bool isImportant = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: categoryColors[doc.category] ?? Colors.grey[300],
          child: Icon(
            categoryIcons[doc.category] ?? Icons.insert_drive_file,
            color: Colors.white,
          ),
        ),
        title: Text(
          doc.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                doc.category,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(doc.createdAt),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: isImportant
            ? const Icon(Icons.star, color: Color(0xFFFFC107))
            : null,
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentViewer(document: doc),
            ),
          );
          
          if (result == true) {
            _loadDocuments();
          }
        },
      ),
    );
  }

  Widget _buildAddDocButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _addDocument,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0066FF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            '+ Thêm tài liệu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
