// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'swipe_page.dart';
import 'search_page.dart';
import 'playlist_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Example',
      home: BottomNavigationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  _BottomNavigationPageState createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _selectedIndex = 1; // To track the currently selected section

  // List of widgets for each section
  final List<Widget> _sections = [
    SearchPage(),
    SwipePage(),
    PlaylistPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: _sections[_selectedIndex], // Display the selected section
    bottomNavigationBar: BottomNavigationBar(
  backgroundColor: const Color.fromARGB(255, 28, 15, 21),
  currentIndex: _selectedIndex, // Highlight the selected item
  onTap: _onItemTapped, // Handle the tap on navigation items
  items: [
    BottomNavigationBarItem(
      icon: _buildCircleIcon(Icons.search, 0),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: _buildCircleIcon(Icons.swipe, 1),
      label: 'Swipe',
    ),
    BottomNavigationBarItem(
      icon: _buildCircleIcon(Icons.table_rows_rounded, 2),
      label: 'Playlist',
    ),
  ],
  elevation: 0, // Remove shadow
  selectedItemColor: const Color.fromARGB(186, 255, 255, 255), // Color for selected text
  unselectedItemColor: Color(0x8A9E9E9E), // Color for unselected text
),
  );
}

Widget _buildCircleIcon(IconData icon, int index) {
  return CircleAvatar(
    radius: 20, // Size of the circle
    backgroundColor: _selectedIndex == index
        ? const Color.fromARGB(212, 255, 255, 255) // Color for the selected icon
        : Color(0x8A9E9E9E), // Color for unselected icons
    child: Icon(
      icon,
      color: const Color.fromARGB(255, 28, 15, 21),
    ),
  );
}

}
