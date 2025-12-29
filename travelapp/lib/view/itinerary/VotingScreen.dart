import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/viewModel/itinerary_view_model.dart';

class VotingScreen extends StatefulWidget {
  final int tripId;
  const VotingScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItineraryViewModel>(context, listen: false).fetchItineraries(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Bình chọn hoạt động", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: const Text(
              "Hãy bình chọn nơi bạn yêu thích nhất.\nHoạt động có số cao nhất sẽ được thêm vào lịch trình",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue, height: 1.5),
            ),
          ),
          Expanded(
            child: Consumer<ItineraryViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading) return const Center(child: CircularProgressIndicator());
                
                final pending = vm.pendingItineraries;
                if (pending.isEmpty) return const Center(child: Text("Không có hoạt động nào đang chờ bình chọn"));

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: pending.length,
                  itemBuilder: (context, index) {
                    final item = pending[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cover Image (Mock)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              "https://images.unsplash.com/photo-1537996194471-e657df975ab4",
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                     const SizedBox(width: 4),
                                     Text(item.activityTime, style: const TextStyle(color: Colors.grey)),
                                     const SizedBox(width: 16),
                                     const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                     const SizedBox(width: 4),
                                     Expanded(
                                       child: Text(
                                         item.locationName, 
                                         style: const TextStyle(color: Colors.grey),
                                         overflow: TextOverflow.ellipsis,
                                       ),
                                     ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(item.description, style: const TextStyle(color: Colors.black54)),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.thumb_up_alt_outlined, color: Colors.blue, size: 20),
                                        const SizedBox(width: 8),
                                        Text("${item.upVotes} bình chọn", style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[100],
                                        foregroundColor: Colors.black,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                                      ),
                                      onPressed: () {
                                         // Vote logic
                                         vm.voteItinerary(item.id, 1, true); // Mock user ID 1
                                      },
                                      child: const Text("Chọn"),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
