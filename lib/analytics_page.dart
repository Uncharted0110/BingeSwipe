import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';
import 'genre_analytics_provider.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedGenre;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabChangeListener); 
  }

  void _tabChangeListener() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_tabChangeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final genreAnalyticsProvider = Provider.of<GenreAnalyticsProvider>(context);
    final selectedAnalytics = _tabController.index == 0
        ? genreAnalyticsProvider.movieGenreFrequency
        : genreAnalyticsProvider.songGenreFrequency;

    final sortedGenres = selectedAnalytics.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final List<Color> colorPalette = [
      Colors.teal.shade300,
      Colors.orange.shade300,
      Colors.pink.shade300,
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.green.shade300,
      Colors.red.shade300,
      Colors.indigo.shade300,
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: const Text(
            'Genre Insights',
            style: TextStyle(color: Colors.white, fontFamily: 'Oswald', fontSize: 40),
          ),
        ),
        bottom: TabBar(
          indicatorColor: Colors.white,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Movies'),
            Tab(text: 'Songs'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey, // Optional for unselected tab color
          labelStyle: const TextStyle(
            fontSize: 18, // Increased font size for selected tab
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16, // Font size for unselected tab
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image with Overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black54,
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Column(
            children: [
              // Total Movies/Songs Liked Card
              Padding(
                padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _tabController.index == 0
                              ? 'Total Movies Liked'
                              : 'Total Songs Liked',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _tabController.index == 0
                              ? '${genreAnalyticsProvider.totalMoviesLiked}'
                              : '${genreAnalyticsProvider.totalSongsLiked}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Treemap Visualization
              Expanded(
                child: sortedGenres.isEmpty
                    ? Center(
                        child: Text(
                          'Swipe to see analytics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : SfTreemap(
                        dataCount: sortedGenres.length,
                        weightValueMapper: (int index) => sortedGenres[index].value.toDouble(),
                        levels: [
                          TreemapLevel(
                            groupMapper: (int index) => sortedGenres[index].key,
                            colorValueMapper: (TreemapTile tile) {
                              // Return the color based on the index of the genre
                              int index = tile.indices[0];
                              return colorPalette[index % colorPalette.length];
                            },
                            color: Colors.transparent,
                            labelBuilder: (BuildContext context, TreemapTile tile) {
                              return Center(
                                child: Text(
                                  '${tile.group}\n${tile.weight.toInt()}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        onSelectionChanged: (TreemapTile tile) {
                          setState(() {
                            final selectedGenre = sortedGenres[tile.indices[0]].key;
                            _selectedGenre = _selectedGenre == selectedGenre ? null : selectedGenre;
                          });
                        },
                      ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
