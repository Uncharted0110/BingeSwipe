import 'package:flutter/material.dart';
import 'flask/movie_services.dart';

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
      elevation: 8, // Added elevation for a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 28, 15, 21),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 4), // Shadow direction
              ),
            ],
          ),
          child: Center(
            child: Text(
              playlistName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2, // Added spacing for a cleaner look
              ),
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
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
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
            child: FutureBuilder<List<Map<String, dynamic>>>( // Fetch items for the playlist
              future: fetchItemsForPlaylist(playlistName),
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
                        margin: const EdgeInsets.all(8),
                        color: Colors.black.withOpacity(0.6),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          horizontalTitleGap: 3,
                          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          leading: movie['image_url'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    movie['image_url'],
                                    width: 50,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.movie, size: 40, color: Colors.white),
                          title: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              movie['song'] ?? movie['title'], // Song name if available, otherwise fallback to title
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Oswald',
                                fontSize: 22,
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
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No playlists available',
                          style: TextStyle(color: Colors.white),
                        ),
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

