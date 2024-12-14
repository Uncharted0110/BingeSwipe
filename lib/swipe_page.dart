import 'dart:convert';
import 'dart:io';
import 'package:bingeswipe/genre_analytics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> movieCardData = [];
  List<Map<String, dynamic>> songCardData = [];
  bool isLoading = true;
  String error = '';

  String selectedCategory = "Movies"; // Default category
  bool showCards = true;
  bool showFinalCard = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  int swipedRightCount = 0;
  int swipedLeftCount = 0;

  List<Map<String, dynamic>> swipedRightItems = [];
  Map<String, dynamic> finalCard = {};

   // Analytics logic
  Future<void> saveGenreAnalytics(List<Map<String, dynamic>> swipedRightMovies) async {
    // Step 1: Extract genres from swiped-right movies
    List<String> genres = [];
    for (var movie in swipedRightMovies) {
      if (movie["genre"] != null) {
        final genreList = (movie["genre"] as String).split(", ").map((e) => e.trim()).toList();
        genres.addAll(genreList);
      }
    }

    // Step 2: Calculate genre frequency
    Map<String, int> genreFrequency = {};
    for (var genre in genres) {
      genreFrequency[genre] = (genreFrequency[genre] ?? 0) + 1;
    }

    // Step 3: Save analytics to a JSON file
    final analytics = {
      "totalMoviesLiked": swipedRightMovies.length,
      "genresLiked": genreFrequency,
    };

    const filePath = "genre_analytics.json";
    final file = File(filePath);

    try {
      await file.writeAsString(json.encode(analytics), flush: true);
      print("Genre analytics saved successfully to $filePath");
    } catch (e) {
      print("Failed to save genre analytics: $e");
    }

    // Optional: Debug output
    print("Genre Analytics: $analytics");
  }

   void _onMovieSwipeRight(Map<String, dynamic> movie) {
    // Extract genres and update provider
    final genres = (movie["genre"] as String).split(", ").map((e) => e.trim()).toList();
    Provider.of<GenreAnalyticsProvider>(context, listen: false).addMovieGenres(genres);
  }

  void _onSongSwipeRight(Map<String, dynamic> movie) {
    // Extract genres and update provider
    final genres = (movie["genre"] as String).split(", ").map((e) => e.trim()).toList();
    Provider.of<GenreAnalyticsProvider>(context, listen: false).addSongGenres(genres);
  }

  @override
  void initState() {
    super.initState();
    fetchMovies();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<Map<String, dynamic>> getRecommendation() async {
  try {
    // Collect genre preferences from swiped items
    List<String> genrePreferences = [];
    
    for (var item in swipedRightItems) {
      if (selectedCategory == "Movies") {
        // For movies, genre is already a list (or comma-separated string)
        final genres = (item["genre"] is List) 
            ? (item["genre"] as List).map((e) => e.toString()).toList()
            : (item["genre"] as String).split(", ");
        genrePreferences.addAll(genres);
      } else {
        // For songs, genre is a single string
        final genre = item["genre"] as String;
        genrePreferences.add(genre);
      }
    }

    // Remove duplicates and take unique genres
    genrePreferences = genrePreferences.toSet().toList();

    // Make API call to get recommendation
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/get_recommendation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'category': selectedCategory,
        'genres': genrePreferences
      }),
    );

    if (response.statusCode == 200) {
      final recommendation = json.decode(response.body);
      return recommendation;
    } else {
      // Fallback if API call fails
      return {
        "title": "No Recommendations",
        "description": "Try swiping on more cards!",
        "image": "https://via.placeholder.com/300x200.png?text=No+Recommendation",
        "genre": "N/A"
      };
    }
  } catch (e) {
    print('Recommendation error: $e');
    return {
      "title": "No Recommendations",
      "description": "Error fetching recommendations",
      "image": "https://via.placeholder.com/300x200.png?text=Error",
      "genre": "N/A"
    };
  }
}


  Future<void> fetchMovies() async {
    const String baseUrl = 'http://127.0.0.1:5000/moviesSwipe';
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> movieData = json.decode(response.body);
        setState(() {
          movieCardData = movieData
              .map((movie) => {
                    "title": movie["title"] ?? "No Title",
                    "description": movie["description"] ?? "No Description",
                    "image": movie["image_url"] ?? "https://via.placeholder.com/300x200.png?text=Movie+Image",
                    "genre": (movie["genre"] as List<dynamic>?)?.join(", ") ?? "No Genre",
                  })
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load movies: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load movies: $e';
        isLoading = false;
      });
    }
  }

 Future<void> fetchSongs() async {
  const String baseUrl = 'http://127.0.0.1:5000/songsSwipe';
  try {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> songData = json.decode(response.body);
      setState(() {
        songCardData = songData
            .map((song) => {
                  "title": song["song"] ?? "No Title", // Use "song" key for title
                  "description": song["genre"] ?? "No Genre",
                  "genre": song["genre"],
                  "image": song["image_url"] ?? "https://via.placeholder.com/300x200.png?text=Song+Image", // Correct image key
                })
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        error = 'Failed to load songs: ${response.statusCode}';
        isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      error = 'Failed to load songs: $e';
      isLoading = false;
    });
  }
}

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void restart() {
  setState(() {
    showCards = true;
    showFinalCard = false;
  });
  
  fetchMovies();
  fetchSongs();
}

  Widget buildCard(String title, String description, String imageUrl) {
  
  return Stack(
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Image.network(
                "https://via.placeholder.com/300x200.png?text=Image+Not+Found",
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            // Delay description appearance
            AnimatedOpacity(
              opacity: 1.0, // Fade in after 1 second
              duration: const Duration(seconds: 1),
              child: Text(
                description,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}


  // Build the roller with swipe gesture to switch between Movies and Songs
  Widget buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = selectedCategory == "Movies" ? "Songs" : "Movies";
                _animationController.forward(from: 0.0);
                isLoading = true; // Show loading indicator while fetching data
              });
              if (selectedCategory == "Movies") {
                fetchMovies();
              } else {
                fetchSongs();
              }
            },
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.1415927,
                  child: child,
                );
              },
              child: Text(
                selectedCategory,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

@override
Widget build(BuildContext context) {
  if (isLoading) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (error.isNotEmpty) {
    return Scaffold(
      body: Center(
        child: Text(
          error,
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      ),
    );
  }

  final cardData = selectedCategory == "Movies" ? movieCardData : songCardData;

  return Scaffold(
    body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Color.fromRGBO(0, 0, 0, 0.5),
          ),
        ),
        Column(
          children: [
            buildCategorySelector(),
            Expanded(
              child: Center(
                child: showCards
                    ? CardSwiper(
                        cardsCount: cardData.length,
                        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final cardWidth = constraints.maxWidth * 0.9;
                              final cardHeight = constraints.maxHeight * 1.0;
                              return Center(
                                child: SizedBox(
                                  width: cardWidth,
                                  height: cardHeight,
                                  child: buildCard(
                                    cardData[index]["title"]!,
                                    cardData[index]["description"]!,
                                    cardData[index]["image"]!,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        threshold: 100,
                        scale: 0.9,
                        onSwipe: (index, threshold, direction) {
                          if (direction == CardSwiperDirection.right) {
                            swipedRightCount++;
                            print('Swiped Right: $swipedRightCount');
                            swipedRightItems.add(cardData[index]);
                            if(selectedCategory == "Movies"){
                            _onMovieSwipeRight(movieCardData[index]);
                            }else{
                              _onSongSwipeRight(songCardData[index]);
                            }
                          } else if (direction == CardSwiperDirection.left) {
                            swipedLeftCount++;
                            print('Swiped Left: $swipedLeftCount');
                          }
                          return true;
                        },
                        onEnd: () async {
                          // Fetch recommendation asynchronously
                          final recommendation = await getRecommendation();
                          setState(() {
                            showCards = false;
                            showFinalCard = true;

                            if(selectedCategory == "Movies"){
                            // Use recommendation data for finalCard
                            finalCard = {
                              "title": recommendation["title"] ?? "No Recommendations",
                              "description": recommendation["description"] ?? "Swipe right to get recommendations!",
                              "image": recommendation["image_url"] ?? "https://via.placeholder.com/300x200.png?text=No+Image",
                            };
                            } else{
                              finalCard = {
                              "title": recommendation['song'] ?? "No Recommendations",
                              "description": recommendation['genre'] ?? "Swipe right to get recommendations!",
                              "image": recommendation['image_url'] ?? "https://via.placeholder.com/300x200.png?text=No+Image",
                            };
                            }
                            
                          });
                           // Step: Save genre analytics after recommendations are shown
                        if (selectedCategory == "Movies") {
                          await saveGenreAnalytics(swipedRightItems);
                        }
                          await Future.delayed(const Duration(milliseconds: 300));
                          _animationController.forward();
                        },
                      )
                    : showFinalCard
                        ? SlideTransition(
                            position: _slideAnimation,
                            child: Center(
                              child: SizedBox(
                                width: 300,
                                height: 450,
                                child: buildCard(
                                  finalCard["title"]!,
                                  finalCard["description"]!,
                                  finalCard["image"]!,
                                ),
                              ),
                            ),
                          )
                        : const Text(
                            "No more cards to show!",
                            style: TextStyle(fontSize: 24, color: Colors.grey),
                          ),
              ),
            ),
          ],
        ),
        if (showFinalCard)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: restart,
              backgroundColor: const Color.fromARGB(255, 28, 15, 21),
              foregroundColor: const Color.fromARGB(186, 255, 255, 255),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: const Color.fromARGB(186, 255, 255, 255),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.replay),
            ),
          ),
      ],
    ),
  );
}
}
