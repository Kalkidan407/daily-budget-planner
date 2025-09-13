import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controlles/trancaction_controller.dart';
import 'Views/home_screen.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionController()),
      ],
      child: const MyApp()
    ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}) ;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return 
   MaterialApp(
    debugShowCheckedModeBanner: false,
        title: 'Daily Budget Planner',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
      ),
      home: const HomeScreen(),
    );
  }
}

