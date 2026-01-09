import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';
import 'package:travelapp/viewModel/auth_view_model.dart';
import 'package:travelapp/view/trip/TripDashboard.dart';
import 'package:travelapp/view/auth/LoginScreen.dart';
import 'package:travelapp/view/user/ProfileScreen.dart';
import 'package:travelapp/models/user_model.dart';
import 'package:travelapp/view/trip/CreateTripScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch trips when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      if (authVM.userId != null) {
        Provider.of<TripViewModel>(context, listen: false).fetchTrips(authVM.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildTripListHeader(),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<TripViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (viewModel.error != null) {
                    return Center(child: Text(viewModel.error!));
                  }

                  return Stack(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: viewModel.trips.length + 1,
                        itemBuilder: (itemContext, index) {
                          if (index == viewModel.trips.length)
                            return const SizedBox(height: 80);
                          final trip = viewModel.trips[index];
                          return GestureDetector(
                            onTap: () async {
                              print("DEBUG: Going to TripDashboard");
                              // Use the State's context, which is stable
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TripDashboard(tripId: trip.id),
                                ),
                              );
                              
                              print("DEBUG: Returned from TripDashboard");
                              // Check State's mounted property
                              if (!mounted) {
                                print("DEBUG: HomeScreen State is NOT mounted. Aborting refresh.");
                                return;
                              }
                              
                              print("DEBUG: State mounted. Getting AuthViewModel...");
                              final authVM = Provider.of<AuthViewModel>(context, listen: false);
                              int? userId = authVM.userId;

                              print("DEBUG: Provider userId: $userId");

                              if (userId == null) {
                                print("DEBUG: Provider userId unavailable, checking SharedPreferences...");
                                try {
                                  final prefs = await SharedPreferences.getInstance();
                                  userId = prefs.getInt('auth_user_id');
                                  print("DEBUG: SharedPreferences userId: $userId");
                                } catch (e) {
                                  print("DEBUG: Error reading SharedPreferences: $e");
                                }
                              }

                              if (userId != null) {
                                  print("DEBUG: Executing fetchTrips for user $userId");
                                  Provider.of<TripViewModel>(context, listen: false).fetchTrips(userId);
                              } else {
                                  print("DEBUG: FATAL - Could not determine userId for refresh.");
                              }
                            },
                            child: _TripCard(
                              imageUrl: trip.coverImage.isNotEmpty 
                                  ? trip.coverImage 
                                  : '',
                              title: trip.tripName,
                              location: trip.description,
                              date: _formatDate(trip.startDate, trip.endDate),
                              members: trip.members,
                              peopleCount: trip.memberCount,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: FloatingActionButton(
                          onPressed: () async {
                           final result = await Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => const CreateTripScreen()),
                             );
                             
                             if (result == true && mounted) {
                               final authVM = Provider.of<AuthViewModel>(context, listen: false);
                               if (authVM.userId != null) {
                                 Provider.of<TripViewModel>(context, listen: false).fetchTrips(authVM.userId!);
                               }
                             }
                          },
                          backgroundColor: Colors.blue,
                          shape: const CircleBorder(),
                          child: const Icon(Icons.add, size: 32, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '';
    try {
      return '${start.month}/${start.day} - ${end.month}/${end.day}/${end.year}';
    } catch (_) {
      return '';
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Xin chào, af!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sẵn sàng cho chuyến đi tiếp theo?',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none_outlined, size: 28),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm chuyến đi',
          prefixIcon: Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTripListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chuyến đi của bạn',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
           Consumer<TripViewModel>(
            builder: (context, vm, _) => Text(
              '${vm.trips.length} active trips',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}



class _TripCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String date;
  final List<User> members;
  final int peopleCount;

  const _TripCard({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.date,
    required this.members,
    required this.peopleCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                 if (imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                 else
                    _buildPlaceholder(),

                // Gradient Overlay
                Container(
                    height: 150,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        ),
                    ),
                ),
                Positioned(
                    bottom: 30,
                    left: 12, right: 12,
                    child: Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                    ),
                ),
                Positioned(
                    bottom: 10,
                    left: 12,
                    child: Row(
                        children: [
                            const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                                location,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                        ],
                    ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          '$peopleCount người',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    
                    // Avatars
                    Row(
                        children: members.take(4).map((member) {
                             // Simple color generation based on name length or char code
                             final color = Colors.primaries[member.username.length % Colors.primaries.length];
                             return Padding(
                               padding: const EdgeInsets.only(left: 4),
                               child: CircleAvatar(
                                 radius: 12, // Small avatar
                                 backgroundColor: color,
                                 child: Text(
                                   member.username.isNotEmpty ? member.username[0].toUpperCase() : '?',
                                   style: const TextStyle(color: Colors.white, fontSize: 10),
                                 ),
                               ),
                             );
                        }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[200], // Light grey as requested
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
