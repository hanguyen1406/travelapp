import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/viewModel/itinerary_view_model.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';
import 'package:travelapp/models/trip_model.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:travelapp/data/services/openmap_service.dart';
import 'package:intl/intl.dart';

class SuggestActivity extends StatefulWidget {
  final int tripId;
  const SuggestActivity({Key? key, required this.tripId}) : super(key: key);

  @override
  State<SuggestActivity> createState() => _SuggestActivityState();
}

class _SuggestActivityState extends State<SuggestActivity> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay(hour: 8, minute: 0);
  int _dayNumber = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Thêm hoạt động", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Tên hoạt động"),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration("e.g. Visit Tanah Lot Temple"),
            ),
            const SizedBox(height: 20),
            
            _buildLabel("Ngày"),
            _buildDaySelector(),
            const SizedBox(height: 20),

            _buildLabel("Giờ"),
            GestureDetector(
              onTap: () async {
                 final time = await showTimePicker(context: context, initialTime: _selectedTime);
                 if (time != null) setState(() => _selectedTime = time);
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: _inputDecoration("").copyWith(
                    prefixIcon: Icon(Icons.access_time),
                    hintText: _selectedTime.format(context)
                  ),
                ),
              ),
            ),
             const SizedBox(height: 20),
             
            _buildLabel("Vị trí"),
            TypeAheadField(
              debounceDuration: const Duration(milliseconds: 1000),
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: _inputDecoration("e.g. Tabanan, Bali").copyWith(
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                );
              },
              suggestionsCallback: (pattern) async {
                return await OpenMapService().getLocationSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                final map = suggestion as Map<String, String>;
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(map['name']!),
                  subtitle: Text(map['address']!, maxLines: 1, overflow: TextOverflow.ellipsis),
                );
              },
              onSelected: (suggestion) {
                final map = suggestion as Map<String, String>;
                _locationController.text = map['name']!;
              },
            ),
             const SizedBox(height: 20),
             
            _buildLabel("Mô tả (tùy chọn)"),
             TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _inputDecoration("Thêm thông tin chi tiết..."),
            ),
             const SizedBox(height: 30),
             
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.blue,
                   padding: EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                 ),
                 onPressed: () async {
                    if (_titleController.text.isEmpty) return;
                    
                    final data = {
                      'title': _titleController.text,
                      'description': _descriptionController.text,
                      'activityTime': '${_selectedTime.hour.toString().padLeft(2,'0')}:${_selectedTime.minute.toString().padLeft(2,'0')}',
                      'locationName': _locationController.text,
                      'dayNumber': _dayNumber,
                      'tripId': widget.tripId,
                      'status': 'PENDING', // Default to pending/voting
                      'suggestedById': 1 // Mock user ID or from Provider
                    };
                    
                    // Call ViewModel
                    final success = await Provider.of<ItineraryViewModel>(context, listen: false)
                        .createItinerary(widget.tripId, data);
                        
                    if (success) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi khi tạo")));
                    }
                 },
                 child: Text("Lưu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      filled: true,
      fillColor: Colors.white
    );
  }
  
  Widget _buildDaySelector() {
     final vm = Provider.of<TripViewModel>(context, listen: false);
     final trip = vm.trips.firstWhere((t) => t.id == widget.tripId, orElse: () => Trip(
       id: 0, tripName: '', description: '', coverImage: '', createdById: 0, createdByName: '', currency: '', 
       startDate: DateTime.now(), endDate: DateTime.now().add(Duration(days: 5))
     )); // Fallback or handle null safely

     if (trip.startDate == null || trip.endDate == null) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
             border: Border.all(color: Colors.grey[300]!),
             borderRadius: BorderRadius.circular(12)
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _dayNumber,
              isExpanded: true,
              items: List.generate(10, (index) => index + 1).map((day) {
                return DropdownMenuItem(value: day, child: Text("Ngày $day"));
              }).toList(),
              onChanged: (val) => setState(() => _dayNumber = val!),
            ),
          ),
        );
     }

     final days = trip.endDate!.difference(trip.startDate!).inDays + 1;
     
     return Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
           border: Border.all(color: Colors.grey[300]!),
           borderRadius: BorderRadius.circular(12)
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _dayNumber,
            isExpanded: true,
            menuMaxHeight: 300, // Limit height to ~5 items
            icon: Icon(Icons.keyboard_arrow_down),
            items: List.generate(days, (index) {
               final date = trip.startDate!.add(Duration(days: index));
               final dateStr = DateFormat('dd/MM/yyyy').format(date);
               return DropdownMenuItem(
                 value: index + 1,
                 child: Text("Ngày ${index + 1} - $dateStr"),
               );
            }).toList(),
            onChanged: (val) => setState(() => _dayNumber = val!),
          ),
        ),
     );
  }
}
