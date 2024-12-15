import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'genre_analytics_provider.dart';

// Utility to convert genres into a list of strings
List<String> convertToGenreList(dynamic genre) {
  if (genre == null) return [];
  if (genre is List) {
    return genre.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
  }
  if (genre is String) {
    return genre.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
  return [];
}

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> movieCardData = [];
  List<Map<String, dynamic>> songCardData = [];
  List<Map<String, dynamic>> swipedRightItems = [];
  Map<String, dynamic> finalCard = {};

  bool isLoading = true;
  bool showCards = true;
  bool showFinalCard = false;
  String error = '';
  String selectedCategory = "Movies";

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Initial data fetch
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    if (selectedCategory == "Movies") {
      await fetchMovies();
    } else {
      await fetchSongs();
    }
  }

  Future<void> fetchMovies() async {
    const String baseUrl = 'http://127.0.0.1:5000/moviesSwipe';
    await fetchDataFromApi(baseUrl, (data) {
      movieCardData = data
          .map((movie) => {
                "title": movie["title"] ?? "No Title",
                "description": movie["description"] ?? "No Description",
                "image": movie["image_url"] ?? "https://via.placeholder.com/300x200.png?text=Movie+Image",
                "genre": (movie["genre"] as List<dynamic>?)?.join(", ") ?? "No Genre",
              })
          .toList();
    });
  }

  Future<void> fetchSongs() async {
    const String baseUrl = 'http://127.0.0.1:5000/songsSwipe';
    await fetchDataFromApi(baseUrl, (data) {
      songCardData = data
          .map((song) => {
                "title": song["song"] ?? "No Title",
                "description": (song["genre"] is List 
                    ? (song["genre"] as List).join(", ") 
                    : song["genre"] ?? "No Genre"),
                "genre": convertToGenreList(song["genre"]),
                "image": song["image_url"] ?? "https://via.placeholder.com/300x200.png?text=Song+Image",
              })
          .toList();
    });
  }

  Future<void> fetchDataFromApi(String url, Function(List<dynamic>) onSuccess) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        onSuccess(json.decode(response.body));
      } else {
        setState(() => error = 'Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => error = 'Failed to load data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>> getRecommendation() async {
    try {
      final genrePreferences = swipedRightItems
          .expand((item) => convertToGenreList(item["genre"]))
          .toSet()
          .toList();

      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/get_recommendation'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category': selectedCategory,
          'genres': genrePreferences,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Recommendation error: $e');
    }
    return {
      "title": "No Recommendations",
      "description": "Try swiping on more cards!",
      "image": "https://via.placeholder.com/300x200.png?text=No+Recommendation",
    };
  }

  void onSwipe(Map<String, dynamic> item, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      swipedRightItems.add(item);
      final genres = convertToGenreList(item["genre"]);
      if (selectedCategory == "Movies") {
        Provider.of<GenreAnalyticsProvider>(context, listen: false).addMovieGenres(genres);
      } else {
        Provider.of<GenreAnalyticsProvider>(context, listen: false).addSongGenres(genres);
      }
    }
  }

  Future<void> onEndSwipe() async {
    final recommendation = await getRecommendation();
    setState(() {
      showCards = false;
      showFinalCard = true;
      finalCard = {
        "title": recommendation["title"] ?? recommendation["song"] ?? "No Recommendations",
        "description": recommendation["genre"] is List
            ? (recommendation["genre"] as List).join(", ")
            : recommendation["description"] ?? "Swipe right to get recommendations!",
        "image": recommendation["image_url"] ?? "https://via.placeholder.com/300x200.png?text=No+Image",
      };
    });
    if (selectedCategory == "Movies") {
      await saveGenreAnalytics(swipedRightItems);
    }
    _animationController.forward();
  }

  Future<void> saveGenreAnalytics(List<Map<String, dynamic>> items) async {
    final genres = items
        .expand((item) => convertToGenreList(item["genre"]))
        .toList();

    final genreFrequency = <String, int>{};
    for (var genre in genres) {
      genreFrequency[genre] = (genreFrequency[genre] ?? 0) + 1;
    }

    final analytics = {
      "totalLiked": items.length,
      "genresLiked": genreFrequency,
    };

    try {
      await File("genre_analytics.json").writeAsString(json.encode(analytics), flush: true);
      debugPrint("Analytics saved: $analytics");
    } catch (e) {
      debugPrint("Error saving analytics: $e");
    }
  }

  Widget buildCard(String title, String description, String imageUrl) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        // Card Background Image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.network(
              "https://via.placeholder.com/300x200.png?text=Image+Not+Found",
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Bright-to-Dark Gradient Overlay
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.transparent, // Bright color
                Colors.black.withOpacity(0.8), // Darker color
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Card Border
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white, // White border
              width: 4, // Border width
            ),
          ),
        ),
        // Card Content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Text
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Description Text
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = selectedCategory == "Movies" ? "Songs" : "Movies";
            fetchData();
          });
        },
        child: Text(
          selectedCategory,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error.isNotEmpty) {
      return Scaffold(body: Center(child: Text(error, style: const TextStyle(color: Colors.red))));
    }

    final cards = selectedCategory == "Movies" ? movieCardData : songCardData;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          Column(
            children: [
              buildCategorySelector(),
              Expanded(
                child: showCards
                    ? CardSwiper(
                        cardsCount: cards.length,
                        cardBuilder: (context, index, _, __) {
                          final card = cards[index];
                          return buildCard(
                            card["title"]!,
                            card["description"]!,
                            card["image"]!,
                          );
                        },
                        onSwipe: (index, _, direction) {
                          onSwipe(cards[index], direction);
                          return true; // Indicate that the swipe was accepted
                        },
                        onEnd: onEndSwipe,
                      )
                    : showFinalCard
                        ? SlideTransition(
                            position: _slideAnimation,
                            child: buildCard(
                              finalCard["title"]!,
                              finalCard["description"]!,
                              finalCard["image"]!,
                            ),
                          )
                        : const Center(child: Text("No more cards!", style: TextStyle(fontSize: 24))),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: showFinalCard
          ? FloatingActionButton(
              onPressed: () => setState(() {
                showCards = true;
                showFinalCard = false;
                fetchData();
              }),
              child: const Icon(Icons.replay),
            )
          : null,
    );
  }
}
