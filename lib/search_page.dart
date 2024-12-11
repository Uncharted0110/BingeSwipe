import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg.jpg'), // Path to the image
            fit: BoxFit.cover, // Ensures the image covers the screen
          ),
        ),
        child: Stack(
          children: [
            // Semi-transparent black overlay
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent black layer
            ),
            // Main content on top of the overlay
            Align(
              alignment: Alignment.topCenter, // Align to top center
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Optional: Adds padding around the search box
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Aligns to the top of the screen
                  crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
                  children: [
                    // Search Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 28, 15, 21), // Opaque background color
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.white), // Icon color changes to white for visibility
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onChanged: (value) {
                                setState(() {
                                  _searchText = value;
                                });
                              },
                              style: TextStyle(color: Colors.white), // Text color changes to white for visibility
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(color: Colors.white), // Hint text color changes to white
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Search Text: $_searchText',
                      style: TextStyle(fontSize: 18, color: Colors.white), // Text color changes to white
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
