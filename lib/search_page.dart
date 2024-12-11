import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = TextEditingController();
  String _searchText = '';
  List<Map<String, String>> _moviesData = [];
  String _errorMessage = '';

  Future<void> fetchMovies(String title) async {
    var url = "http://127.0.0.1:5000/searchMovieByTitle?title=$title";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          _moviesData = data
              .map<Map<String, String>>((movie) => {
                    'title': movie['"title"'] ?? 'No Title Available',
                    'description': movie['"description"'] ?? 'No Description Available',
                    'image_url': movie['"image_url"'] ?? '',
                  })
              .toList();
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = 'No movies found matching the title.';
          _moviesData = [];
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Failed to fetch movies: ${response.statusCode}';
        _moviesData = [];
      });
    }
  }

  void _showDescriptionPopup(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(color: Colors.black.withOpacity(0.5)),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Search Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 28, 15, 21),
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.white),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onChanged: (value) {
                                setState(() {
                                  _searchText = value;
                                });
                              },
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_searchText.isNotEmpty) {
                          fetchMovies(_searchText);
                        }
                      },
                      child: const Text('Search'),
                    ),
                    const SizedBox(height: 20),
                    // Display Results
                    if (_moviesData.isNotEmpty)
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of cards per row
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8, // Adjusted for card size
                          ),
                          itemCount: _moviesData.length,
                          itemBuilder: (context, index) {
                            final movie = _moviesData[index];
                            return GestureDetector(
                              onTap: () {
                                _showDescriptionPopup(context, movie['title']!, movie['description']!);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                  border: Border.all(color: Colors.white, width: 2), // White border
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10), // Match border radius
                                  child: Stack(
                                    children: [
                                      // Background Image
                                      movie['image_url'] != null && movie['image_url']!.isNotEmpty
                                          ? Image.network(
                                              movie['image_url']!,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover, // Ensures the image fills the card space
                                            )
                                          : Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: Colors.grey,
                                              child: const Center(
                                                child: Text(
                                                  'No Image Available',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                      // Title Overlay
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          color: Colors.black.withOpacity(0.6), // Semi-transparent background for better readability
                                          child: Text(
                                            movie['title'] ?? 'No Title',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
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
