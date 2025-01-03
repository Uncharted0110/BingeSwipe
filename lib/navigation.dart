import 'package:flutter/material.dart';
import 'search_page.dart';
import 'swipe_page.dart';
import 'playlist_page.dart';
import 'analytics_page.dart'; // Import AnalyticsPage

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});
  @override
  _BottomNavigationPageState createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _selectedIndex = 1;

  // List of widgets for each section
  late final List<Widget> _sections;

  @override
  void initState() {
    super.initState();
    _sections = [
      SearchPage(),
      SwipePage(),
      PlaylistPage(),
      AnalyticsPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sections[_selectedIndex], // Display the selected section
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 28, 15, 21), 
        padding: const EdgeInsets.symmetric(vertical: 8), //
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.search, 'Search', 0),
            _buildNavItem(Icons.swipe, 'Swipe', 1),
            _buildNavItem(Icons.table_rows_rounded, 'Playlists', 2),
            _buildNavItem(Icons.analytics, 'Analytics', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(212, 255, 255, 255) // Highlighted background color
                  : const Color(0x8A9E9E9E), // Default background color
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8), // Padding inside the circle
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? const Color.fromARGB(255, 28, 15, 21) // Icon color when selected
                  : const Color.fromARGB(255, 255, 255, 255), // Icon color when unselected
            ),
          ),
          const SizedBox(height: 4), // Spacing between icon and label
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color.fromARGB(186, 255, 255, 255) // Selected label color
                  : const Color(0x8A9E9E9E), // Unselected label color
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
