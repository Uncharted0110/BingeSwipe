import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with SingleTickerProviderStateMixin {
  final List<Map<String, String>> movieCardData = [
    {
      "title": "Whiplash",
      "description": "This is the description of card 1.",
      "image": "https://m.media-amazon.com/images/M/MV5BMTU0NzQ2ODQ0OF5BMl5BanBnXkFtZTgwOTM1NTE4MjE@._V1_FMjpg_UY2048_.jpg",
    },
    {
      "title": "Interstellar",
      "description": "This is the description of card 2.",
      "image": "https://m.media-amazon.com/images/M/MV5BYzdjMDAxZGItMjI2My00ODA1LTlkNzItOWFjMDU5ZDJlYWY3XkEyXkFqcGc@._V1_QL75_UX380_CR0,0,380,562_.jpg",
    },
    {
      "title": "(500) Days of Summer",
      "description": "This is the description of card 3.",
      "image": "https://m.media-amazon.com/images/M/MV5BMTk5MjM4OTU1OV5BMl5BanBnXkFtZTcwODkzNDIzMw@@._V1_QL75_UX380_CR0,12,380,562_.jpg",
    },
  ];

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
  late Animation<double> _rotationAnimation; // Rotation animation

  @override
  void initState() {
    super.initState();
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
            image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            border: Border.all(color: Colors.white, width: 6),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
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
                style: const TextStyle(fontSize: 18, color: Colors.white),
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
              // Toggle between "Movies" and "Songs" on every tap
              setState(() {
                selectedCategory = selectedCategory == "Movies" ? "Songs" : "Movies";
                _animationController.forward(from: 0.0); // Trigger animation
              });
            },
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.1415927, // 360 degrees rotation
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
    final cardData = selectedCategory == "Movies" ? movieCardData : songCardData;
    final finalCard = selectedCategory == "Movies"
        ? {
            "title": "Movie Finale",
            "description": "This is the final movie card.",
            "image": "https://via.placeholder.com/300x200.png?text=Final+Movie+Card",
          }
        : {
            "title": "Song Finale",
            "description": "This is the final song card.",
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
              buildCategorySelector(), // Roller for selecting Movies or Songs
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
