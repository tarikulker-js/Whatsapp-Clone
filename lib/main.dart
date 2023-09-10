import 'package:flutter/material.dart';
import 'package:whatsapp/components/Appbar.dart';
import 'package:whatsapp/screens/HomeScreen.dart';
import 'package:whatsapp/screens/LoginScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    MaterialColor customColor = MaterialColor(
      0xFF000000,
      const {
        50: Color(0xFF000000),
        100: Color(0xFF000000),
        200: Color(0xFF000000),
        300: Color(0xFF000000),
        400: Color(0xFF000000),
        500: Color(0xFF000000),
        600: Color(0xFF000000),
        700: Color(0xFF000000),
        800: Color(0xFF000000),
        900: Color(0xFF000000),
      },
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp',
      theme: ThemeData(
        primaryColor: customColor,
      ),
      home: Scaffold(
        backgroundColor: customColor,
        body: LoginScreen(),
      ),
    );
  }
}