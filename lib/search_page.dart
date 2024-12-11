import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import for debounce

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _moviesData = [];
  String _errorMessage = '';
  Timer? _debounce;

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
                    'line': movie['"line"'] ?? 'No line',
                    'r_year': movie['"r_year"'] ?? 'Not released',
                    'genre': (movie['"genre"'] ?? []).join(', '),
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

void _showDescriptionPopup(BuildContext context, Map<String, dynamic> movie) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // To allow scrolling and fit large content
    backgroundColor: Colors.transparent, // Transparent background for the modal itself
    builder: (context) {
      // Get screen width using MediaQuery
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      // Set dynamic image width and height as a percentage of the screen size
      double dynamicImageWidth = screenWidth * 0.35; // Image width = 30% of screen width
      double dynamicImageHeight = screenHeight * 0.3; // Image height = 25% of screen height

      // Set maxWidth dynamically based on the screen size
      double dynamicMaxWidth = screenWidth * 0.6; // For example, 60% of screen width

      return Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'), // Replace with your image asset path
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken), // Darken the image for readability
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7), // Content background color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row for the image (left) and movie title/description (right)
              Row(
                children: [
                  // Left column with image, release year, and genre
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie image with dynamic width and height
                      movie['image_url'] != ''
                          ? Container(
                              width: dynamicImageWidth, // Dynamic image width
                              height: dynamicImageHeight, // Dynamic image height
                              margin: const EdgeInsets.only(right: 15),
                              child: Image.network(
                                movie['image_url'] ?? '',
                                fit: BoxFit.cover,
                              ),
                            )
                          : const SizedBox(), // Show nothing if image is unavailable

                      const SizedBox(height: 10),

                      // Release Year
                      Text(
                        'Release Year: ${movie['r_year'] ?? 'Not Released'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),

                      // Genre (genre will wrap if needed)
                      Container(
                        width: dynamicImageWidth, // Limit to dynamic image width
                        child: Text(
                          'Genre: ${movie['genre'] ?? 'No Genre'}',
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.visible, // Allow genre text to wrap
                          maxLines: 2, // Allow genre text to wrap into the next line if necessary
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 15),

                  // Right column with title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Movie title with wrapping
                        Text(
                          movie['title'] ?? 'No Title Available',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                          softWrap: true, // Enable text wrapping
                          overflow: TextOverflow.ellipsis, // Add ellipsis if title overflows
                          maxLines: 2, // Allow title to wrap to 2 lines if necessary
                        ),
                        const SizedBox(height: 10),

                        // Movie description (wrapped text)
                        Container(
                          constraints: BoxConstraints(maxWidth: dynamicMaxWidth), // Dynamically set max width
                          child: Text(
                            movie['description'] ?? 'No Description Available',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                            softWrap: true, // Wrap text to the next line
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Movie tagline or line at the bottom center (wrapped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '"${movie['line'] ?? 'No line'}"',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                  softWrap: true, // Allow the line to wrap if necessary
                  overflow: TextOverflow.visible, // Allow it to wrap
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}




  void _onSearchTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (text.isNotEmpty) {
        fetchMovies(text);
      } else {
        setState(() {
          _moviesData = [];
        });
      }
    });
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
                              onChanged: _onSearchTextChanged,
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
                                _showDescriptionPopup(context, movie);
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
