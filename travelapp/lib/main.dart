import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:travelapp/viewModel/auth_view_model.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';
import 'package:travelapp/viewModel/itinerary_view_model.dart';
import 'package:travelapp/viewModel/checklist_view_model.dart';
import 'package:travelapp/viewModel/expense_view_model.dart';
import 'package:travelapp/view/bill/ExpenseList.dart';
import 'package:travelapp/view/auth/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
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
        ChangeNotifierProvider(create: (_) => ChecklistViewModel()),
        ChangeNotifierProvider(create: (_) => ExpenseViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Travel App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LoginScreen(),
      ),
    );
  }
}
