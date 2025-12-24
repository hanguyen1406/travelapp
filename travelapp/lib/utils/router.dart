import 'package:flutter/material.dart';
import '../feature/trip/HomeScreen.dart';
import '../feature/trip/CreateTripScreen.dart';
import '../feature/trip/TripDashboard.dart';
import '../feature/trip/TripDetailScreen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/create':
        return MaterialPageRoute(builder: (_) => CreateTripScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => TripDashboard());
      case '/detail':
        return MaterialPageRoute(builder: (_) => TripDetailScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for \'${settings.name}\''),
            ),
          ),
        );
    }
  }
}
