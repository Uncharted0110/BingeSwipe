import 'package:flutter/material.dart';
import 'movie_services.dart'; // Import the service functions
import 'dart:async';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _moviesData = [];
  String _errorMessage = '';
  Timer? _debounce;
  String _searchType = 'Title'; // Default to Title search

  @override
  void initState() {
    super.initState();
    _fetchAllMovies(); // Fetch all movies when the page loads
  }

  Future<void> _fetchAllMovies() async {
    try {
      List<Map<String, String>> movies = await fetchAllMovies();
      setState(() {
        _moviesData = movies;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _moviesData = [];
      });
    }
  }

  void _onSearchTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (text.isNotEmpty) {
        try {
          List<Map<String, String>> movies;
          if (_searchType == 'Title') {
            movies = await fetchMoviesByTitle(text);
          } else if (_searchType == 'Genre'){
            movies = await fetchMoviesByGenre(text);
          } else {
            movies = await fetchMoviesByActor(text);
          }
          setState(() {
            _moviesData = movies;
            _errorMessage = '';
          });
        } catch (e) {
          setState(() {
            _errorMessage = e.toString();
            _moviesData = [];
          });
        }
      } else {
        _fetchAllMovies(); // Show all movies when search is cleared
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Add a text search field above the existing search box
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Search Movies',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Oswald',
                        ),
                      ),
                    ),
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
                              onChanged: _onSearchTextChanged,
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white, // Change cursor color to white
                              decoration: InputDecoration(
                                hintText: 'Search by $_searchType',
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          DropdownButton<String>(
                            value: _searchType,
                            dropdownColor: const Color.fromARGB(255, 28, 15, 21),
                            items: <String>['Title', 'Genre', 'Actor'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16, // Adjusted font size
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _searchType = newValue!;
                              });
                            },
                            underline: const SizedBox(), // Remove dropdown underline
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Display Results
                    if (_moviesData.isNotEmpty)
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _moviesData.length,
                          itemBuilder: (context, index) {
                            final movie = _moviesData[index];
                            return GestureDetector(
                              onTap: () => showDescriptionPopup(context, movie),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.grey, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    children: [
                                      movie['image_url'] != null && movie['image_url']!.isNotEmpty
                                          ? Image.network(
                                              movie['image_url']!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            )
                                          : Container(
                                              color: Colors.grey,
                                              child: const Center(
                                                child: Text(
                                                  'No Image Available',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          color: Colors.black.withOpacity(0.6),
                                          child: Text(
                                            movie['title'] ?? 'No Title',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: Colors.white, fontSize: 16),
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
