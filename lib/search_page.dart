import 'package:flutter/material.dart';
import 'flask/movie_services.dart'; // Import the service functions
import 'flask/song_services.dart'; // Import song service functions
import 'dart:async';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controllerTab1 = TextEditingController();
  final TextEditingController _controllerTab2 = TextEditingController();

  late TabController _tabController;

  List<Map<String, String>> _moviesData = [];
  List<Map<String, String>> _songsData = [];
  String _errorMessageTab1 = '';
  String _errorMessageTab2 = '';
  Timer? _debounceTab1;
  Timer? _debounceTab2;
  String _searchTypeTab1 = 'Title'; // Default to Title search for Tab 1
  String _searchTypeTab2 = 'Track'; // Default to Track search for Tab 2

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAllMovies();
    _fetchAllSongs();
  }

  Future<void> _fetchAllMovies() async {
    try {
      List<Map<String, String>> movies = await fetchAllMovies();
      setState(() {
        _moviesData = movies;
        _errorMessageTab1 = '';
      });
    } catch (e) {
      setState(() {
        _errorMessageTab1 = e.toString();
        _moviesData = [];
      });
    }
  }

  Future<void> _fetchAllSongs() async {
    try {
      List<Map<String, String>> songs = await fetchAllSongs();
      setState(() {
        _songsData = songs;
        _errorMessageTab2 = '';
      });
    } catch (e) {
      setState(() {
        _errorMessageTab2 = e.toString();
        _songsData = [];
      });
    }
  }

  void _onSearchTextChangedTab1(String text) {
    if (_debounceTab1?.isActive ?? false) _debounceTab1?.cancel();
    _debounceTab1 = Timer(const Duration(milliseconds: 500), () async {
      if (text.isNotEmpty) {
        try {
          List<Map<String, String>> movies;
          if (_searchTypeTab1 == 'Title') {
            movies = await fetchMoviesByTitle(text);
          } else if (_searchTypeTab1 == 'Genre') {
            movies = await fetchMoviesByGenre(text);
          } else {
            movies = await fetchMoviesByActor(text);
          }
          setState(() {
            _moviesData = movies;
            _errorMessageTab1 = '';
          });
        } catch (e) {
          setState(() {
            _errorMessageTab1 = e.toString();
            _moviesData = [];
          });
        }
      } else {
        _fetchAllMovies();
      }
    });
  }

  void _onSearchTextChangedTab2(String text) {
    if (_debounceTab2?.isActive ?? false) _debounceTab2?.cancel();
    _debounceTab2 = Timer(const Duration(milliseconds: 500), () async {
      if (text.isNotEmpty) {
        try {
          List<Map<String, String>> songs;
          if (_searchTypeTab2 == 'Track') {
            songs = await fetchSongsByTrack(text);
          } else if (_searchTypeTab2 == 'Genre') {
            songs = await fetchSongsByGenre(text);
          } else {
            songs = await fetchSongsByArtist(text);
          }
          setState(() {
            _songsData = songs;
            _errorMessageTab2 = '';
          });
        } catch (e) {
          setState(() {
            _errorMessageTab2 = e.toString();
            _songsData = [];
          });
        }
      } else {
        _fetchAllSongs();
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
                    // Heading
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Oswald',
                        ),
                      ),
                    ),
                    // Tabs
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Movies'),
                        Tab(text: 'Songs'),
                      ],
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSearchTab(
                            controller: _controllerTab1,
                            onSearchTextChanged: _onSearchTextChangedTab1,
                            searchType: _searchTypeTab1,
                            onSearchTypeChanged: (value) => setState(() => _searchTypeTab1 = value!),
                            data: _moviesData,
                            errorMessage: _errorMessageTab1,
                            isMoviesTab: true, // Movies tab
                          ),
                          _buildSearchTab(
                            controller: _controllerTab2,
                            onSearchTextChanged: _onSearchTextChangedTab2,
                            searchType: _searchTypeTab2,
                            onSearchTypeChanged: (value) => setState(() => _searchTypeTab2 = value!),
                            data: _songsData,
                            errorMessage: _errorMessageTab2,
                            isMoviesTab: false, // Songs tab
                          ),
                        ],
                      ),
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

  Widget _buildSearchTab({
    required TextEditingController controller,
    required Function(String) onSearchTextChanged,
    required String searchType,
    required Function(String?) onSearchTypeChanged,
    required List<Map<String, String>> data,
    required String errorMessage,
    required bool isMoviesTab,
  }) {
    return Column(
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
                  controller: controller,
                  onChanged: onSearchTextChanged,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Search by $searchType',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: searchType,
                dropdownColor: const Color.fromARGB(255, 28, 15, 21),
                items: isMoviesTab
                    ? <String>['Title', 'Genre', 'Actor']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ))
                        .toList()
                    : <String>['Track', 'Genre', 'Artist/Album']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ))
                        .toList(),
                onChanged: onSearchTypeChanged,
                underline: const SizedBox(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Results
        if (data.isNotEmpty)
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return GestureDetector(
                  onTap: () => showDescriptionPopup(context, item),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          item['image_url'] != null && item['image_url']!.isNotEmpty
                              ? Image.network(
                                  item['image_url']!,
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
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                item['title'] ?? 'No Title',
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
        if (errorMessage.isNotEmpty)
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
      ],
    );
  }
}
