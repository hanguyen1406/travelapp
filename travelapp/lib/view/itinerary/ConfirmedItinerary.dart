import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/viewModel/itinerary_view_model.dart';

class ConfirmedItinerary extends StatefulWidget {
  final int tripId;
  const ConfirmedItinerary({Key? key, required this.tripId}) : super(key: key);

  @override
  State<ConfirmedItinerary> createState() => _ConfirmedItineraryState();
}

class _ConfirmedItineraryState extends State<ConfirmedItinerary> {
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
        title: const Text("Xác nhận lịch trình", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: Consumer<ItineraryViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator());

          // Group by Day
          final confirmed = vm.confirmedItineraries;
          // Mock data filtering for now if actual API returns mixed
          // For logic: just sort by day and time
          confirmed.sort((a,b) {
             int dayComp = a.dayNumber.compareTo(b.dayNumber);
             if (dayComp != 0) return dayComp;
             return a.activityTime.compareTo(b.activityTime);
          });
          
          if (confirmed.isEmpty) {
             return Center(child: Text("Chưa có lịch trình được xác nhận"));
          }

          // Map to groupings
          Map<int, List<dynamic>> grouped = {};
          for(var item in confirmed) {
             if (!grouped.containsKey(item.dayNumber)) grouped[item.dayNumber] = [];
             grouped[item.dayNumber]!.add(item);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8E6CF).withOpacity(0.5), // Green-ish
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                       Container(
                         padding: const EdgeInsets.all(4),
                         decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                         child: const Icon(Icons.check, size: 12, color: Colors.white),
                       ),
                       const SizedBox(width: 12),
                       const Expanded(
                         child: Text(
                           "Lịch trình cho nhóm đã được xác nhận!\nSẵn sàng cho chuyến đi thật tuyệt vời.",
                           style: TextStyle(color: Color(0xFF2D5A46), fontSize: 13),
                         ),
                       )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                ...grouped.entries.map((entry) {
                   int day = entry.key;
                   List items = entry.value;
                   return Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       _buildDayHeader(day, items.length),
                       const SizedBox(height: 12),
                       ...items.map((item) => _buildItem(item)).toList(),
                       const SizedBox(height: 24),
                     ],
                   );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayHeader(int day, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ngày $day", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text("Dec 15, 2024", style: TextStyle(color: Colors.grey, fontSize: 12)), // Mock date
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text("$count hoạt động", style: const TextStyle(color: Colors.white, fontSize: 11)),
        )
      ],
    );
  }

  Widget _buildItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Image.network(
              "https://images.unsplash.com/photo-1537996194471-e657df975ab4",
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(item.activityTime + " • 1h", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                       const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                       const SizedBox(width: 4),
                       Expanded(child: Text(item.locationName, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
