import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controlles/trancaction_controller.dart';
import 'Views/homeScreen.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}) ;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return 
    ChangeNotifierProvider(
      create: (context) => TransactionController(),
    

    child: MaterialApp(
      title: 'Daily Budget Planner',
      theme: ThemeData(
        
        primarySwatch: Colors.indigo,
     
      ),
      home: const HomeScreen(),
    ));
  }
}

