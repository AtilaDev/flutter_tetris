import 'package:flutter/material.dart';
import 'board.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const HomePage(),
        '/gameboard': (context) => const GameBoard()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
