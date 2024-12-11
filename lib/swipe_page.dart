import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:http/http.dart' as http;

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> movieCardData = [];
  bool isLoading = true;
  String error = '';

  final List<Map<String, String>> songCardData = [
    {
      "title": "Bohemian Rhapsody",
      "description": "Queen's classic hit song.",
      "image": "https://via.placeholder.com/300x200.png?text=Bohemian+Rhapsody",
    },
    {
      "title": "Imagine",
      "description": "John Lennon's timeless anthem.",
      "image": "https://via.placeholder.com/300x200.png?text=Imagine",
    },
    {
      "title": "Hotel California",
      "description": "The Eagles' most iconic track.",
      "image": "https://via.placeholder.com/300x200.png?text=Hotel+California",
    },
  ];

  String selectedCategory = "Movies"; // Default category
  bool showCards = true;
  bool showFinalCard = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

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

  Future<void> fetchMovies() async {
    const String baseUrl = 'http://127.0.0.1:5000/movies';
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> movieData = json.decode(response.body);
        setState(() {
          movieCardData = movieData
              .map((movie) => {
                    "title": movie['\"title\"'] ?? "No Title",
                    "description": movie['\"description\"'] ?? "No Description",
                    "image": movie['\"image_url\"'] ?? "https://via.placeholder.com/300x200.png?text=Movie+Image",
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
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(fontSize: 15, color: Colors.white),
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
              });
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
    // Handle loading state
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Handle error state
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
    final finalCard = selectedCategory == "Movies"
        ? {
            "title": "Movie Finale",
            "description": "No more movies to swipe!",
            "image": "https://via.placeholder.com/300x200.png?text=Final+Movie+Card",
          }
        : {
            "title": "Song Finale",
            "description": "No more songs to swipe!",
            "image": "https://via.placeholder.com/300x200.png?text=Final+Song+Card",
          };

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                          onEnd: () async {
                            setState(() {
                              showCards = false;
                            });
                            await Future.delayed(const Duration(milliseconds: 300));
                            setState(() {
                              showFinalCard = true;
                            });
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
          // Add restart button after final card is shown
          if (showFinalCard)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: restart,
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                child: const Icon(Icons.replay),
              ),
            ),
        ],
      ),
    );
  }
}