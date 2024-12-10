import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final List<Container> cards = [
    Container(
      alignment: Alignment.center,
      color: Colors.blue,
      child: const Text(
        '1',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    ),
    Container(
      alignment: Alignment.center,
      color: Colors.red,
      child: const Text(
        '2',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    ),
    Container(
      alignment: Alignment.center,
      color: Colors.purple,
      child: const Text(
        '3',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    ),
  ];

  bool showCards = true; // Flag to toggle card visibility
  bool showFinalCard = false; // Flag to show the final card

  void restart() {
    setState(() {
      showCards = true;
      showFinalCard = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: showCards
          ? CardSwiper(
              cardsCount: cards.length,
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) =>
                  cards[index],
              threshold: 100,
              scale: 0.9,
              onEnd: () async {
                setState(() {
                  showCards = false; // Hide the card swiper
                });
                await Future.delayed(const Duration(seconds: 1)); // Wait for 1 second
                setState(() {
                  showFinalCard = true; // Show the final card
                });
              },
            )
          : showFinalCard
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 200,
                      width: 300,
                      alignment: Alignment.center,
                      color: Colors.green,
                      child: const Text(
                        "Final Card",
                        style: TextStyle(fontSize: 24, color: Colors.white),
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
