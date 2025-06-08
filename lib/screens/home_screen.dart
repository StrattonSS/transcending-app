import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent app bar over gradient
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Transcending"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
          // Future: Show admin button here conditionally
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x40000000), // Black
              Color(0x40784F17), // Brown
              Color(0x405BCEFA), // Trans Blue
              Color(0x40F5A9B8), // Trans Pink
              Color(0x40FFFFFF), // White
              Color(0x40FF0000), // Red
              Color(0x40FF8C00), // Orange
              Color(0x40FFFF00), // Yellow
              Color(0x40008000), // Green
              Color(0x400000FF), // Blue
              Color(0x408B00FF), // Purple
            ],
          ),
        ),
        child: const Center(
          child: Text(
            "Welcome to the Transcending Home Page!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 3,
                  color: Colors.black54,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
