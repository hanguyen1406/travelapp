import 'package:travelapp/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';
import 'package:travelapp/viewModel/auth_view_model.dart';
import 'package:travelapp/data/services/openmap_service.dart';
import 'package:travelapp/data/services/image_search_service.dart';
import 'package:travelapp/models/user_model.dart';
import 'package:travelapp/models/trip_model.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({Key? key}) : super(key: key);

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  List<User> members = [];
  bool isLoading = false;
  String? _coverImageUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      
      // Check if we need to fetch user details
      if ((authVM.loginResponse?.user == null || authVM.loginResponse!.user!.email!.isEmpty) && authVM.userId != null) {
         await authVM.fetchUserDetails(authVM.userId!);
      }

      final user = authVM.loginResponse?.user;
      if (user != null) { 
        setState(() {
             members.add(User(
                 id: user.id ?? 0,
                 name: user.name ?? '',
                 surname: user.surname ?? '',
                 username: user.username ?? '',
                 email: user.email ?? '',
             ));
        });
      }
    });
  }

  Future<List<Map<String, String>>> fetchLocationSuggestions(String query) async {
    return await OpenMapService().getLocationSuggestions(query);
  }

  Future<void> _fetchAndSetImage(String query) async {
      final url = await ImageSearchService().fetchImageFromGoogle(query);
      if (url != null && mounted) {
          setState(() {
              _coverImageUrl = url;
          });
      }
  }

  Future<void> _createTrip() async {
    if (_nameController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        _startDate == null ||
        _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
      );
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final body = {
      'tripName': _nameController.text,
      'description': _destinationController.text,
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'coverImage': _coverImageUrl ?? '', 
      'createdBy': {'id': authVM.userId}, // Fixed: Send object instead of flat ID
      // 'members': [], // Remove this, as we add members separately and it might confuse backend deserialization if not strictly typed
      // 'memberCount': 1, // Optional, backend likely ignores or calculates this
    };
    
    // setState(() => isLoading = true); 
    
    final vm = Provider.of<TripViewModel>(context, listen: false);
    final Trip? newTrip = await vm.createTrip(body);

    if (newTrip != null) {
      for (var member in members) {
          if (member.id != authVM.userId) { 
              await vm.addMember(newTrip.id, {'userId': member.id.toString()});
          }
      }

      if (!mounted) return;
      Navigator.pop(context, true); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo chuyến đi thành công!')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo thất bại: ${vm.error}')),
      );
    }
  }

  void _showAddMemberSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String inputValue = '';
        bool isEmailTab = true;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
               padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thêm Thành Viên',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => isEmailTab = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isEmailTab ? Colors.blue : const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.email_outlined, size: 18, color: isEmailTab ? Colors.white : Colors.black54),
                                const SizedBox(width: 8),
                                Text('Email', style: TextStyle(color: isEmailTab ? Colors.white : Colors.black54, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => isEmailTab = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isEmailTab ? Colors.blue : const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.tag, size: 18, color: !isEmailTab ? Colors.white : Colors.black54),
                                const SizedBox(width: 8),
                                Text('User ID', style: TextStyle(color: !isEmailTab ? Colors.white : Colors.black54, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                   TypeAheadField<User>(
                    debounceDuration: const Duration(milliseconds: 500),
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: isEmailTab ? 'Tìm theo email...' : 'Nhập ID người dùng...',
                          prefixIcon: Icon(isEmailTab ? Icons.email_outlined : Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue)),
                        ),
                      );
                    },
                    suggestionsCallback: (pattern) async {
                      if (pattern.isEmpty) return [];
                      final vm = Provider.of<TripViewModel>(context, listen: false);
                      return await vm.searchUsers(pattern);
                    },
                    itemBuilder: (context, User suggestion) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(suggestion.username.isNotEmpty ? suggestion.username[0].toUpperCase() : 'U', style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(suggestion.username),
                        subtitle: Text(suggestion.email),
                      );
                    },
                    onSelected: (User suggestion) {
                      if (!members.any((m) => m.id == suggestion.id)) {
                          setState(() {
                              members.add(suggestion);
                          });
                      }
                      Navigator.pop(context);
                    },
                    emptyBuilder: (context) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Không tìm thấy người dùng'),
                    ),
                  ),
                  const SizedBox(height: 250),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Tạo Chuyến Đi Mới',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Tên chuyến đi',
                  labelStyle: TextStyle(fontSize: 13),
                  hintText: 'VD: Đà Lạt Mùa Xuân',
                  hintStyle: TextStyle(fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TypeAheadField<Map<String, String>>(
                controller: _destinationController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Điểm đến',
                      labelStyle: const TextStyle(fontSize: 13),
                      hintText: 'VD: Đà Lạt, Lâm Đồng',
                      hintStyle: const TextStyle(fontSize: 13),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  );
                },
                suggestionsCallback: fetchLocationSuggestions,
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(suggestion['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(suggestion['address']!, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  );
                },
                onSelected: (suggestion) {
                   _destinationController.text = suggestion['name']!;
                   _fetchAndSetImage(suggestion['name']!);
                },
              ),
              if (_coverImageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _coverImageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150, 
                        color: Colors.grey[200], 
                        child: Center(child: Icon(Icons.broken_image, color: Colors.grey))
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thành viên (${members.length})',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: _showAddMemberSheet,
                    child: const Text('+ Thêm'),
                  ),
                ],
              ),
               
               if (members.isNotEmpty)
                Column(
                    children: members.map<Widget>((User m) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                            children: [
                                CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Text(m.username.isNotEmpty ? m.username[0].toUpperCase() : 'U', style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(m.username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                            Text(m.email, style: TextStyle(color: Colors.grey, fontSize: 11)),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    )).toList(),
                ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Ngày đi',
                            labelStyle: TextStyle(fontSize: 13),
                            hintText: '',
                            hintStyle: TextStyle(fontSize: 13),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          controller: TextEditingController(
                            text: _startDate == null
                                ? ''
                                : '${_startDate!.day.toString().padLeft(2, '0')}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.year}',
                          ),
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _endDate = picked);
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Ngày về',
                            labelStyle: TextStyle(fontSize: 13),
                            hintText: '',
                            hintStyle: TextStyle(fontSize: 13),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          controller: TextEditingController(
                            text: _endDate == null
                                ? ''
                                : '${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.year}',
                          ),
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: isLoading ? null : _createTrip,
                  child: isLoading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Tạo Chuyến Đi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
