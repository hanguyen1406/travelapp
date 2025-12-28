import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/viewModel/auth_view_model.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';
import 'package:travelapp/viewModel/itinerary_view_model.dart';
import 'view/auth/LoginScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => TripViewModel()),
        ChangeNotifierProvider(create: (_) => ItineraryViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Travel App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginScreen(),
      ),
    );
  }
}
