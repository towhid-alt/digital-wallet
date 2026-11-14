import 'package:flutter/material.dart';

class chatHomeScreen extends StatefulWidget {
  const chatHomeScreen({super.key});

  @override
  State<chatHomeScreen> createState() => _chatHomeScreenState();
}

class _chatHomeScreenState extends State<chatHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Chat Home Screen'),
      ),
    );
  }
}