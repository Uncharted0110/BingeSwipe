// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with SingleTickerProviderStateMixin {
  final List<Map<String, String>> cardData = [
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

  bool showCards = true; // Flag to toggle card visibility
  bool showFinalCard = false; // Flag to show the final card
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  double cardWidth = 300; // Default width of cards
  double cardHeight = 200; // Default height of cards

  void restart() {
    setState(() {
      showCards = true;
      showFinalCard = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start off-screen at the bottom
      end: Offset.zero, // End at its original position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget buildCard(String title, String description, String imageUrl) {
  return Stack(
    children: [
      // Background Image with Gradient Overlay
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.7), // Dark at the top
                Colors.transparent, // Light at the bottom
              ],
            ),
          ),
        ),
      ),
      // Card Content
      Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end, // Align content at the bottom
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: showCards
          ? CardSwiper(
              cardsCount: cardData.length,
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                // Use LayoutBuilder to dynamically set card dimensions
                return LayoutBuilder(
                  builder: (context, constraints) {
                    cardWidth = constraints.maxWidth * 0.9; // Increased width multiplier
                    cardHeight = constraints.maxHeight * 0.8; // Increased height multiplier
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
                  showCards = false; // Hide the card swiper
                });
                await Future.delayed(const Duration(milliseconds: 300)); // Short delay
                setState(() {
                  showFinalCard = true; // Show the final card
                });
                _animationController.forward(); // Start the slide-in animation
              },
            )
          : showFinalCard
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideTransition(
                      position: _slideAnimation,
                      child: Center(
                        child: SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: buildCard(
                            "Final Card",
                            "This is the final card description.",
                            "https://via.placeholder.com/300x200.png?text=Final+Background",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: restart,
                      child: const Text("Restart Swiping"),
                    ),
                  ],
                )
              : const Text(
                  "No more cards to show!",
                  style: TextStyle(fontSize: 24, color: Colors.grey),
                ),
    );
  }
}