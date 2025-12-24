import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';
import 'package:travelapp/viewModel/itinerary_view_model.dart';
import 'package:travelapp/view/trip/HomeScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripViewModel()),
        ChangeNotifierProvider(create: (_) => ItineraryViewModel()),
      ],
      child: MaterialApp(
        title: 'Travel App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
