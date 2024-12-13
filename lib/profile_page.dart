import 'package:flutter/material.dart';
import 'movie_services.dart';

// Playlist Card Widget
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
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
    );
  }
}

// Movie List Overlay that displays movies in a scrollable list
class MovieListOverlay extends StatelessWidget {
  final String playlistName;

  const MovieListOverlay({
    super.key,
    required this.playlistName,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
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
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else {
                final movies = snapshot.data!;
                return ListView.builder(
                  controller: scrollController,
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 5,
                      child: ListTile(
                        leading: movie['image_url'] != null
                            ? Image.network(
                                movie['image_url'],
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.movie, size: 50, color: Colors.white),
                        title: Text(
                          movie['title'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          movie['description'],
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        );
      },
    );
  }
}

// Profile Page that displays all playlists
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
      appBar: AppBar(
        title: const Text('My Playlists'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<String>>(
        future: fetchExistingPlaylists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load playlists'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No playlists available'));
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
    );
  }
}
