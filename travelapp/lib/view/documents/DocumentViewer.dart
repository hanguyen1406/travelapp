import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added
import '../../repository/document_repository.dart';
import '../../utils/app_config.dart'; // Added

class DocumentViewer extends StatefulWidget {
  final Document document;
  
  const DocumentViewer({
    super.key,
    required this.document,
  });

  @override
  State<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  late bool isImportant;
  bool showMenu = false;
  bool isDeleting = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    isImportant = widget.document.isImportant;
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('auth_token');
    });
  }

  Widget _buildDocumentPreview() {
    final doc = widget.document;
    
    // Debug logic
    print('🔍 [Preview] Name: ${doc.name}');
    print('🔍 [Preview] Type: ${doc.type}');
    print('🔍 [Preview] Url: ${doc.url}');

    final isImage = (doc.type != null && doc.type!.toLowerCase().contains('image')) ||
        doc.name.toLowerCase().endsWith('.jpg') ||
        doc.name.toLowerCase().endsWith('.jpeg') ||
        doc.name.toLowerCase().endsWith('.png') ||
        doc.name.toLowerCase().endsWith('.webp') ||
        (doc.originalFileName != null && (
          doc.originalFileName!.toLowerCase().endsWith('.jpg') ||
          doc.originalFileName!.toLowerCase().endsWith('.jpeg') ||
          doc.originalFileName!.toLowerCase().endsWith('.png') ||
          doc.originalFileName!.toLowerCase().endsWith('.webp')
        ));
        
    print('🔍 [Preview] isImage: $isImage');

    if (isImage && doc.url != null) {
      // Construct full URL if it's relative
      String imageUrl = doc.url!;
      if (!imageUrl.startsWith('http')) {
        // Remove text '/api' if repeated or just join correctly
        if (imageUrl.startsWith('/')) {
             imageUrl = '${AppConfig.baseUrl.replaceAll("/api", "")}$imageUrl';
        } else {
             imageUrl = '${AppConfig.baseUrl}/$imageUrl';
        }
      }
      
      print('🖼️ [DocumentViewer] Final Image URL: $imageUrl');
      print('🔑 [DocumentViewer] Token: ${_token != null ? "Yes" : "No"}');

      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        headers: {
          'ngrok-skip-browser-warning': 'true',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ [DocumentViewer] Image load error: $error');
          print('❌ [DocumentViewer] StackTrace: $stackTrace');
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                _buildPlaceholder(),
                const SizedBox(height: 8),
                Text('Lỗi: $error', style: const TextStyle(color: Colors.red, fontSize: 10), textAlign: TextAlign.center),
            ],
          );
        },
      );
    }
    
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("📄", style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              const Text("Xem trước tài liệu"),
              const SizedBox(height: 4),
              Text(
                widget.document.name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteDocument() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài liệu?'),
        content: const Text('Bạn có chắc chắn muốn xóa tài liệu này không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      isDeleting = true;
    });

    try {
      await DocumentRepository.deleteDocument(widget.document.id);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa tài liệu thành công')),
      );
      
      // Return true to indicate a change (deletion) occurred
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isDeleting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa tài liệu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          /// MAIN CONTENT
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140),
            child: Column(
              children: [

                /// HEADER
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _circleButton(
                                icon: Icons.chevron_left,
                                onTap: () => Navigator.pop(context),
                              ),
                              Row(
                                children: [
                                  _circleButton(
                                    icon: Icons.star,
                                    color: isImportant
                                        ? const Color(0xFFFFB84D)
                                        : Colors.white,
                                    filled: isImportant,
                                    onTap: () {
                                      // TODO: Call API to toggle importance
                                      setState(() => isImportant = !isImportant);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  _circleButton(
                                    icon: Icons.more_vert,
                                    onTap: () {
                                      setState(() => showMenu = !showMenu);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Text(
                            widget.document.name,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${widget.document.type ?? 'Tài liệu'} • ${widget.document.fileSize ?? 'Không rõ kích thước'}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// PREVIEW
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _buildDocumentPreview(),
                    ),
                  ),
                ),

                /// DETAILS
                _glassCard(
                  title: "Chi tiết tài liệu",
                  children: [
                    _row("Danh mục", widget.document.category),
                    _row("Ngày tải lên", widget.document.createdAt.toString().split(' ')[0]),
                    _row("Kích thước", widget.document.fileSize ?? 'Không rõ'),
                    _row("Loại", widget.document.type ?? 'Không rõ'),
                    _row("Tên gốc", widget.document.originalFileName ?? 'N/A'),
                  ],
                ),
              ],
            ),
          ),

          /// BOTTOM ACTIONS
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black.withOpacity(0.5),
                  child: Row(
                    children: [
                      // Only Delete button remains
                      _actionBtn(
                        Icons.delete, 
                        "Xóa", 
                        danger: true,
                        onTap: isDeleting ? null : _deleteDocument,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// MENU OVERLAY
          if (showMenu)
            GestureDetector(
              onTap: () => setState(() => showMenu = false),
              child: Container(
                color: Colors.black54,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.only(top: 100, right: 16),
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _menuItem(
                          Icons.delete, 
                          "Xóa", 
                          danger: true,
                          onTap: () {
                            setState(() => showMenu = false);
                            _deleteDocument();
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
          /// LOADING OVERLAY
          if (isDeleting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

/// ===== Helpers =====

Widget _circleButton({
  required IconData icon,
  Color color = Colors.white,
  bool filled = false,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    ),
  );
}

Widget _glassCard({
  required String title,
  List<Widget>? children,
  Widget? child,
}) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          if (children != null) ...children,
          if (child != null) child,
        ],
      ),
    ),
  );
}

Widget _row(String left, String right) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: const TextStyle(color: Colors.white70)),
        Expanded(
          child: Text(
            right, 
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

// Unused tag widget removed for cleaner code if not needed, or kept if future use intended.
// Keeping it simple based on request to just remove buttons.

Widget _actionBtn(IconData icon, String label, {bool danger = false, VoidCallback? onTap}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: danger ? Colors.red : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}

Widget _menuItem(IconData icon, String text, {bool danger = false, VoidCallback? onTap}) {
  return ListTile(
    leading: Icon(icon, color: danger ? Colors.red : Colors.grey),
    title: Text(
      text,
      style: TextStyle(color: danger ? Colors.red : Colors.black),
    ),
    onTap: onTap ?? () {},
  );
}
