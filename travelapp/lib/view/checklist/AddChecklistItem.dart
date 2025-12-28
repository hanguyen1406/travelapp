import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/models/checklist_model.dart';
import 'package:travelapp/models/user_model.dart';
import 'package:travelapp/viewModel/checklist_view_model.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';

class AddChecklistItem extends StatefulWidget {
  final int tripId;
  final ChecklistItem? editItem;

  const AddChecklistItem({
    Key? key,
    required this.tripId,
    this.editItem,
  }) : super(key: key);

  @override
  State<AddChecklistItem> createState() => _AddChecklistItemState();
}

class _AddChecklistItemState extends State<AddChecklistItem> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  User? _selectedUser;
  List<User> _tripMembers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editItem?.title ?? '');
    _descriptionController = TextEditingController(text: widget.editItem?.description ?? '');
    _selectedUser = null;

    // Load trip members
    Future.microtask(() {
      _loadTripMembers();
    });
  }

  void _loadTripMembers() {
    // For demo, we'll use mock users. In real app, fetch from API
    setState(() {
      _tripMembers = [
        User(
          id: 1,
          email: 'sarah@example.com',
          firstName: 'Sarah',
          lastName: '',
          avatar: null,
        ),
        User(
          id: 2,
          email: 'mia@example.com',
          firstName: 'Mia',
          lastName: '',
          avatar: null,
        ),
        User(
          id: 3,
          email: 'lia@example.com',
          firstName: 'Lia',
          lastName: '',
          avatar: null,
        ),
      ];

      if (widget.editItem?.assignedToUserId != null) {
        _selectedUser = _tripMembers.firstWhere(
          (user) => user.id == widget.editItem!.assignedToUserId,
          orElse: () => _tripMembers.first,
        );
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChecklistItem() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final viewModel = context.read<ChecklistViewModel>();

    if (widget.editItem != null) {
      // Edit existing item
      viewModel
          .updateChecklistItem(
            widget.tripId,
            widget.editItem!.id,
            _titleController.text,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            assignedUserId: _selectedUser?.id,
          )
          .then((success) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${viewModel.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } else {
      // Add new item
      viewModel
          .addChecklistItem(
            widget.tripId,
            _titleController.text,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            assignedUserId: _selectedUser?.id,
          )
          .then((success) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${viewModel.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.editItem != null ? 'Chỉnh sửa công việc' : 'Thêm công việc',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              const Text(
                'Tiêu đề công việc',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập tiêu đề công việc',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 20),

              // Description Input
              const Text(
                'Mô tả chi tiết',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập mô tả chi tiết (tùy chọn)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: 20),

              // Assigned User
              const Text(
                'Giao cho',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<User?>(
                    value: _selectedUser,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('Chọn người thực hiện'),
                    items: [
                      const DropdownMenuItem<User?>(
                        value: null,
                        child: Text('Không giao cho ai'),
                      ),
                      ..._tripMembers.map((user) {
                        return DropdownMenuItem<User?>(
                          value: user,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: _getAvatarColor(user.id),
                                child: Text(
                                  user.firstName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(user.firstName),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (User? user) {
                      setState(() => _selectedUser = user);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Trip Members Display
              if (_tripMembers.isNotEmpty) ...[
                const Text(
                  'Thành viên trong chuyến đi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tripMembers.map<Widget>((user) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedUser?.id == user.id ? const Color(0xFF3B82F6) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: _getAvatarColor(user.id),
                            child: Text(
                              user.firstName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.firstName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _selectedUser?.id == user.id ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Add All Members Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thêm tất cả thành viên vào công việc này'),
                      ),
                    );
                  },
                  child: const Text(
                    'Thêm tất cả thành viên',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width - 32,
        margin: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isLoading ? null : _saveChecklistItem,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  widget.editItem != null ? 'Cập nhật công việc' : 'Thêm công việc',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Color _getAvatarColor(int userId) {
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF10B981), // Green
    ];
    return colors[userId % colors.length];
  }
}
