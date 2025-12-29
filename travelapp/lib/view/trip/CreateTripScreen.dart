import 'package:travelapp/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';
import 'package:travelapp/viewModel/auth_view_model.dart';
import 'package:travelapp/data/services/openmap_service.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({Key? key}) : super(key: key);

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  // Key moved to AppConfig: final String openMapApiKey = "EvckMG80oLeHRhw93ZjYiqztcBvApSEP";
  DateTime? _startDate;
  DateTime? _endDate;
  List<Map<String, String>> members = [];
  bool isLoading = false;

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
          members = [
            {'name': user.username ?? '', 'email': user.email ?? '', 'role': 'Bạn'},
          ];
        });
      } else {
        // Fallback if still missing
        setState(() {
           members = [
            {'name': 'Bạn', 'email': 'me@example.com', 'role': 'Bạn'},
          ];
        });
      }
    });
  }

  void _showAddMemberSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String search = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Email',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.tag,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'User ID',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm theo email...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Color(0xFFF2F4F7),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setModalState(() => search = v),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Nhập email để tìm kiếm',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
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
    
    // Member parsing logic if needed? 
    // Currently sending members as empty list in body, which is fine for now based on previous code.
    
    final body = {
      'tripName': _nameController.text,
      'description': _destinationController.text,
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'coverImage': '',
      'members': [], // Logic to add actual members can be added here
      'memberCount': members.length,
      'createdById': 1, // Mock or retrieve from Auth
    };
    
    // setState(() => isLoading = true); // Optional if using VM loading
    
    final vm = Provider.of<TripViewModel>(context, listen: false);
    final success = await vm.createTrip(body);

    if (success) {
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

  Future<List<Map<String, String>>> fetchLocationSuggestions(String query) async {
    return await OpenMapService().getLocationSuggestions(query);
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
                },
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
              ...members.map(
                (m) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          m['name']![0].toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['name']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              m['email']!,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (m['role'] == 'Bạn')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Bạn',
                            style: TextStyle(color: Colors.blue, fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
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
