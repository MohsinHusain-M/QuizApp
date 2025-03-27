import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() async{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: PopScope(
        canPop: false, //blocks swipe-back gesture
        child: const HomeScreen(),
      ),
    );
  }
}
