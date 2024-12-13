import 'package:flutter/material.dart';
import 'movie_services.dart';

class PlaylistCard extends StatelessWidget {
  final String playlistName;
  final VoidCallback onTap;

  const PlaylistCard({
    super.key,
    required this.playlistName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 28, 15, 21),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Text(
            playlistName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class MovieListOverlay extends StatelessWidget {
  final String playlistName;

  const MovieListOverlay({
    super.key,
    required this.playlistName,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Stack(
        children: [
          // Background Image with White Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/bg.jpg'),
                  fit: BoxFit.cover, // Changed to fitHeight
                  alignment: Alignment.centerLeft, // Align to left vertically
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.8),
                    BlendMode.lighten,
                  ),
                ),
              ),
            ),
          ),
          // Content Container
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchMoviesForPlaylist(playlistName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No movies available',
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                } else {
                  final movies = snapshot.data!;
                  return ListView.builder(
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                    final movie = movies[index];
                    return Card(
                      margin: const EdgeInsets.all(8), // Reduced margin
                      color: Colors.black,
                      elevation: 3, // Reduced elevation
                      child: ListTile(
                        horizontalTitleGap: 3,
                        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5), // Reduced padding
                        leading: movie['image_url'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  movie['image_url'],
                                  width: 50, // Reduced width
                                  height: 150, // Reduced height
                                  fit: BoxFit.cover,
                                ),
                              )
                    : const Icon(Icons.movie, size: 40, color: Colors.white), // Reduced icon size
                      title: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          movie['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Oswald',
                            fontSize: 28, // Reduced font size
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
                );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  void _showMovieOverlay(String playlistName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MovieListOverlay(playlistName: playlistName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Black Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                image: AssetImage('images/bg.jpg'),
                fit: BoxFit.cover,
              ),
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Playlists Heading
              Padding(
                padding: const EdgeInsets.only(top: 25, left: 20),
                child: Text(
                  'Playlists',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Oswald',
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: fetchExistingPlaylists(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Failed to load playlists', 
                          style: TextStyle(color: Colors.white)
                        )
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No playlists available', 
                          style: TextStyle(color: Colors.white)
                        )
                      );
                    } else {
                      final playlists = snapshot.data!;
                      return ListView.builder(
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          return PlaylistCard(
                            playlistName: playlists[index],
                            onTap: () => _showMovieOverlay(playlists[index]),
                          );
                        },
                      );
                    }
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