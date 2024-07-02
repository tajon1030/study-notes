import 'package:flutter/material.dart';
import 'package:spalsh_screen/screen/home_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      theme: ThemeData(
        fontFamily: 'sunflower',
        textTheme: TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontFamily: 'parisienne',
          ),
          displayMedium: TextStyle(
              color: Colors.white,
              fontSize: 50,
              fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    ),
  );
}
