import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/models/trip_model.dart';
import 'package:travelapp/models/user_model.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';
import 'package:travelapp/view/itinerary/ItineraryScreen.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:travelapp/view/checklist/ChecklistScreen.dart';
import 'package:intl/intl.dart';
import 'package:travelapp/view/documents/DocumentVaultScreen.dart';
import '../bill/ExpenseList.dart';

class TripDashboard extends StatefulWidget {
  final int tripId;

  const TripDashboard({Key? key, required this.tripId}) : super(key: key);

  @override
  State<TripDashboard> createState() => _TripDashboardState();
}

class _TripDashboardState extends State<TripDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripViewModel>(
        context,
        listen: false,
      ).fetchTripDetail(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final trip = viewModel.currentTrip;

        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: Text("Error")),
            body: Center(child: Text(viewModel.error ?? "Trip not found")),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          body: Stack(
            children: [
              _buildHeader(trip),
              DraggableScrollableSheet(
                initialChildSize: 0.65,
                minChildSize: 0.65,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMemberSection(trip),
                          const SizedBox(height: 20),
                          _buildDashboardGrid(trip),
                          const SizedBox(height: 30),
                          Center(child: _buildSyncedBadge()),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 40,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Trip trip) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            trip.coverImage.isNotEmpty
                ? trip.coverImage
                : 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black12, Colors.black54],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              trip.tripName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trip.description,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateRange(trip.startDate, trip.endDate),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberSection(Trip trip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "Các thành viên (${trip.memberCount})",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Row(
            children: [
              ...trip.members
                  .take(4)
                  .map(
                    (m) => _buildAvatar(
                      m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                      Colors.blue,
                    ),
                  ),
              if (trip.memberCount > 4)
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      '+${trip.memberCount - 4}',
                      style: const TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => _showAddMemberSheet(trip.id),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.add, size: 16, color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMemberSheet(int tripId) {
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
                  // Tabs
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => isEmailTab = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isEmailTab
                                  ? Colors.blue
                                  : const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 18,
                                  color: isEmailTab
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    color: isEmailTab
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                              color: !isEmailTab
                                  ? Colors.blue
                                  : const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.tag,
                                  size: 18,
                                  color: !isEmailTab
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'User ID',
                                  style: TextStyle(
                                    color: !isEmailTab
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                          hintText: isEmailTab
                              ? 'Tìm theo email...'
                              : 'Nhập ID người dùng...',
                          prefixIcon: Icon(
                            isEmailTab ? Icons.email_outlined : Icons.search,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      );
                    },
                    suggestionsCallback: (pattern) async {
                      if (pattern.isEmpty) return [];
                      final vm = Provider.of<TripViewModel>(
                        context,
                        listen: false,
                      );
                      return await vm.searchUsers(pattern);
                    },
                    itemBuilder: (context, User suggestion) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            suggestion.username.isNotEmpty
                                ? suggestion.username[0].toUpperCase()
                                : 'U',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(suggestion.username),
                        subtitle: Text(suggestion.email),
                      );
                    },
                    onSelected: (User suggestion) async {
                      Navigator.pop(context); // Close sheet
                      final vm = Provider.of<TripViewModel>(
                        context,
                        listen: false,
                      );
                      // Add by User ID regardless of tab, as we have the specific user object
                      final success = await vm.addMember(tripId, {
                        'userId': suggestion.id.toString(),
                      });

                      if (mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã thêm thành viên thành công!'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Thất bại: ${vm.error}')),
                          );
                        }
                      }
                    },
                    emptyBuilder: (context) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Không tìm thấy người dùng'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      'Nhập để tìm kiếm và chọn người dùng',
                      style: TextStyle(color: Colors.grey),
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

  Widget _buildAvatar(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: color,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(Trip trip) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildGridItem(
          "Lịch trình",
          Icons.calendar_today,
          Colors.blue[100]!,
          Colors.blue,
          trip.itineraryCount,
          onTap: () {
            // Navigate to Itinerary Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItineraryScreen(tripId: trip.id),
              ),
            );
          },
        ),
        _buildGridItem(
          "Chi phí",
          Icons.attach_money,
          Colors.green[100]!,
          Colors.green,
          trip.expenseCount,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExpenseListScreen(tripId: trip.id),
              ),
            );
          },
        ),
        _buildGridItem(
          "Tài liệu",
          Icons.description_outlined,
          Colors.orange[100]!,
          Colors.orange,
          trip.documentCount,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DocumentVaultScreen(tripId: trip.id),
              ),
            );
          },
        ),
        _buildGridItem(
          "Đồ đạc",
          Icons.check_box_outlined,
          Colors.pink[100]!,
          Colors.pink,
          trip.checklistCount,
          onTap: () {
            // Navigate to Checklist Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChecklistScreen(tripId: trip.id),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGridItem(
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
    int count, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 30),
                      ),
                      if (count > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "Synced",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return "Date not set";
    final f = DateFormat('MMM dd');
    return "${f.format(start)} - ${f.format(end)}, ${end.year}";
  }
}
