import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/viewModel/itinerary_view_model.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';
import 'package:travelapp/models/trip_model.dart';
import 'package:travelapp/view/itinerary/SuggestActivity.dart';
import 'package:travelapp/view/itinerary/VotingScreen.dart';
import 'package:travelapp/view/itinerary/ConfirmedItinerary.dart'; // Ensure this exists or I create it
import 'package:intl/intl.dart';

class ItineraryScreen extends StatefulWidget {
  final int tripId;
  const ItineraryScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int _selectedDay = 1;

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
        title: const Text("Lịch trình", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (_) => SuggestActivity(tripId: widget.tripId)),
               ).then((_) => Provider.of<ItineraryViewModel>(context, listen: false).fetchItineraries(widget.tripId));
            },
          )
        ],
      ),
      body: Consumer<ItineraryViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final itineraries = vm.itineraries.where((i) => i.dayNumber == _selectedDay).toList();
          // Sort by time
          itineraries.sort((a, b) => a.activityTime.compareTo(b.activityTime));

          // Check for conflicts
          final timeCounts = <String, int>{};
          for (var i in itineraries) {
            timeCounts[i.activityTime] = (timeCounts[i.activityTime] ?? 0) + 1;
          }

          return Column(
            children: [
              _buildDaySelector(),
              Expanded(
                child: itineraries.isEmpty 
                  ? Center(child: Text("Chưa có lịch trình cho ngày này"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: itineraries.length,
                      itemBuilder: (context, index) {
                         final item = itineraries[index];
                         final isConflict = (timeCounts[item.activityTime] ?? 0) > 1;
                         // Build timeline item
                         return _buildTimelineItem(item, index == itineraries.length - 1, isConflict);
                      },
                    ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.symmetric(vertical: 16)
                    ),
                    onPressed: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (_) => VotingScreen(tripId: widget.tripId)),
                       ).then((_) => vm.fetchItineraries(widget.tripId));
                    },
                     // Make it look like the "Thêm hoạt động" button or "Voting" entry
                    child: const Text("Hoạt động đang bình chọn", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildDaySelector() {
    final vm = Provider.of<TripViewModel>(context, listen: false);
    // Find trip safely
    final trip = vm.trips.firstWhere((t) => t.id == widget.tripId, orElse: () => Trip(
       id: 0, tripName: '', description: '', coverImage: '', createdById: 0, createdByName: '', currency: '',
       startDate: DateTime.now(), endDate: DateTime.now().add(Duration(days: 5))
    ));
    
    if (trip.startDate == null || trip.endDate == null) return const SizedBox();

    final days = trip.endDate!.difference(trip.startDate!).inDays + 1;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(days, (index) {
           final day = index + 1;
           final date = trip.startDate!.add(Duration(days: index));
           final dateStr = DateFormat('MMM dd').format(date);
           final isSelected = _selectedDay == day;
           
           return GestureDetector(
             onTap: () => setState(() => _selectedDay = day),
             child: Container(
               margin: const EdgeInsets.only(right: 12),
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
               decoration: BoxDecoration(
                 color: isSelected ? Colors.blue : Colors.grey[100],
                 borderRadius: BorderRadius.circular(24),
               ),
               child: Column(
                 children: [
                   Text("Ngày $day", style: TextStyle(
                     color: isSelected ? Colors.white : Colors.black87,
                     fontWeight: FontWeight.bold
                   )),
                   Text(dateStr, style: TextStyle(
                     color: isSelected ? Colors.white70 : Colors.grey,
                     fontSize: 12
                   )),
                 ],
               ),
             ),
           );
        }),
      ),
    );
  }

  Widget _buildTimelineItem(dynamic item, bool isLast, bool isConflict) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                 margin: const EdgeInsets.symmetric(vertical: 8),
                 width: 12,
                 height: 12,
                 decoration: BoxDecoration(
                   color: isConflict ? Colors.amber : Colors.blue,
                   shape: BoxShape.circle,
                 ),
              ),
              if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  color: Colors.grey[200],
                ),
              )
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isConflict ? Colors.amber.withOpacity(0.5) : Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: isConflict ? Colors.amber[700] : Colors.grey),
                      SizedBox(width: 4),
                      Text(item.activityTime, style: TextStyle(
                        color: isConflict ? Colors.amber[700] : Colors.grey,
                        fontWeight: isConflict ? FontWeight.bold : FontWeight.normal
                      )),
                      if (isConflict) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text("Voting", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      ]
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.locationName, 
                          style: TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (isConflict) ...[
                     SizedBox(height: 12),
                     Divider(height: 1, color: Colors.grey[200]),
                     SizedBox(height: 12),
                     Row(
                       children: [
                         Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.blue),
                         SizedBox(width: 6),
                         Text("${item.upVotes} votes", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500))
                       ],
                     )
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
