import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';

Future<List<Map<String, String>>> fetchAllSongs() async {
  var url = "http://127.0.0.1:5000/getAllSongs";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, String>>((song) => {
              'title': song["song"] ?? 'No Title Available',
              'description': song["song_url"] ?? 'No Description Available',
              'image_url': song["image_url"] ?? '',
              'line': "",
              'r_year': song["r_year"] ?? 'Not released',
              'genre': (song["genre"] ?? []).join(', ') ?? 'No genre',
              'cast': (song["artists"] ?? []).join(', ') ?? 'No cast',
              'director': "",
              'movie_id' : song["song_id"].toString(),
              'language': song["album"]
            })
        .toList();
  } else {
    throw Exception('Failed to fetch all song: ${response.statusCode}');
  }
}

// Fetch songs by title
Future<List<Map<String, String>>> fetchSongsByTrack(String name) async {
  var url = "http://127.0.0.1:5000/searchSongByTrack?name=$name";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, String>>((song) => {
              'title': song["song"] ?? 'No Title Available',
              'description': song["song_url"] ?? 'No Description Available',
              'image_url': song["image_url"] ?? '',
              'line': "",
              'r_year': song["r_year"] ?? 'Not released',
              'genre': (song["genre"] ?? []).join(', ') ?? 'No genre',
              'cast': (song["artists"] ?? []).join(', ') ?? 'No cast',
              'director': "",
              'movie_id' : song["song_id"].toString(),
              'language': song["album"]
            })
        .toList();
  } else {
    throw Exception('Failed to fetch song by name: ${response.statusCode}');
  }
}

// Fetch songs by artists
Future<List<Map<String, String>>> fetchSongsByArtist(String artist) async {
  var url = "http://127.0.0.1:5000//searchSongByArtist?artist=$artist";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, String>>((song) => {
              'title': song["song"] ?? 'No Title Available',
              'description': song["song_url"] ?? 'No Description Available',
              'image_url': song["image_url"] ?? '',
              'line': "",
              'r_year': song["r_year"] ?? 'Not released',
              'genre': (song["genre"] ?? []).join(', ') ?? 'No genre',
              'cast': (song["artists"] ?? []).join(', ') ?? 'No cast',
              'director': "",
              'movie_id' : song["song_id"].toString(),
              'language': song["album"]
            })
        .toList();
  } else {
    throw Exception('Failed to fetch song by artist: ${response.statusCode}');
  }
}

// Fetch movies by genre
Future<List<Map<String, String>>> fetchSongsByGenre(String genre) async {
  var url = "http://127.0.0.1:5000/searchSongByGenre?genre=$genre";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, String>>((song) => {
              'title': song["song"] ?? 'No Title Available',
              'description': song["song_url"] ?? 'No Description Available',
              'image_url': song["image_url"] ?? '',
              'line': "",
              'r_year': song["r_year"] ?? 'Not released',
              'genre': (song["genre"] ?? []).join(', ') ?? 'No genre',
              'cast': (song["artists"] ?? []).join(', ') ?? 'No cast',
              'director': "",
              'movie_id' : song["song_id"].toString(),
              'language': song["album"]
            })
        .toList();
  } else {
    throw Exception('Failed to fetch song by genre: ${response.statusCode}');
  }
}

// Fetch movies by genre
Future<List<Map<String, String>>> fetchSongsByAlbum(String album) async {
  var url = "http://127.0.0.1:5000/searchSongByAlbum?album=$album";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, String>>((song) => {
              'title': song["song"] ?? 'No Title Available',
              'description': song["song_url"] ?? 'No Description Available',
              'image_url': song["image_url"] ?? '',
              'line': "",
              'r_year': song["r_year"] ?? 'Not released',
              'genre': (song["genre"] ?? []).join(', ') ?? 'No genre',
              'cast': (song["artists"] ?? []).join(', ') ?? 'No cast',
              'director': "",
              'movie_id' : song["song_id"].toString(),
              'language': song["album"]
            })
        .toList();
  } else {
    throw Exception('Failed to fetch song by genre: ${response.statusCode}');
  }
}

class AudioPlayerHelper {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playFullAudio(String audioUrl) async {
    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
      throw Exception('Failed to play audio: ${e.toString()}');
    }
  }

  void dispose() {
    // Dispose this instance of the player
    _audioPlayer.dispose();
  }
}

void showSongDescription(BuildContext context, Map<String, dynamic> movie) {
  final AudioPlayerHelper audioPlayerHelper = AudioPlayerHelper();
  String statusMessage = '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      double dynamicImageWidth = screenWidth * 0.45;
      double dynamicImageHeight = screenHeight * 0.3;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          void playAudio(String audioUrl) async {
            try {
              setModalState(() {
                statusMessage = 'Preparing to play audio...';
              });
              await audioPlayerHelper.playFullAudio(audioUrl);
              setModalState(() {
                statusMessage = 'Audio playing successfully!';
              });
            } catch (e) {
              setModalState(() {
                statusMessage = 'Error: ${e.toString()}';
              });
            }
          }

          return Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                movie['image_url'] != ''
                                    ? Container(
                                        width: dynamicImageWidth,
                                        height: dynamicImageHeight,
                                        margin: const EdgeInsets.only(right: 15),
                                        child: Image.network(
                                          movie['image_url'] ?? '',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const SizedBox(),
                                const SizedBox(height: 10),
                                Text(
                                  movie['r_year'] ?? 'Not Released',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width: dynamicImageWidth,
                                  child: Text(
                                    movie['genre'] ?? 'No Genre',
                                    style: const TextStyle(fontSize: 16),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                SizedBox(height: 10,),
                                IconButton(
                                  icon: Icon(Icons.playlist_add, size: 30),
                                  onPressed: () async {
                                    String? playlistName = await _showPlaylistDialog(context);

                                    if (playlistName != null && playlistName.isNotEmpty) {
                                      await _addItemToPlaylist(playlistName, movie['movie_id'], 'song');
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie['title'],
                                    style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Oswald'),
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Album: ${movie['language'] ?? 'N/A'}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    'Artists: ${movie['cast']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 35),
                                  GestureDetector(
                                    onTap: () {
                                      final audioUrl =
                                          movie["description"] ??
                                              'https://example.com/audio.mp3'; // Replace with your audio URL
                                      if (audioUrl.isNotEmpty) {
                                        playAudio(audioUrl);
                                      } else {
                                        setModalState(() {
                                          statusMessage = 'No audio available!';
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(0.8),
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Status Message
                        Center(
                          child: Text(
                            statusMessage,
                            style: TextStyle(
                              fontSize: 16,
                              color: statusMessage.contains('Error')
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Play Audio Button at Bottom-Right
                ],
              ),
            ),
          );
        },
      );
    },
  ).whenComplete(() => audioPlayerHelper.dispose()); // Dispose audio player on sheet close
}

Future<String?> _showPlaylistDialog(BuildContext context) async {
  List<String> existingPlaylists = await fetchExistingPlaylists();
  TextEditingController controller = TextEditingController();
  String? selectedPlaylist;

  return showDialog<String>(
    // ignore: use_build_context_synchronously
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Select or Enter Playlist Name'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown for existing playlists
                DropdownButton<String>(
                  value: selectedPlaylist,
                  hint: Text('Select an existing playlist'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPlaylist = newValue; // Update the state
                    });
                  },
                  items: existingPlaylists.map<DropdownMenuItem<String>>((String playlist) {
                    return DropdownMenuItem<String>(
                      value: playlist,
                      child: Text(playlist),
                    );
                  }).toList(),
                ),
                // TextField for a new playlist
                TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: "New playlist name"),
                  onChanged: (text) {
                    setState(() {
                      // Add to the playlist dynamically if not already present
                      if (text.isNotEmpty && !existingPlaylists.contains(text)) {
                        existingPlaylists.add(text);
                      }
                      selectedPlaylist = text.isNotEmpty ? text : null; // Update the state
                    });
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(selectedPlaylist);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}


// Function to send item (movie or song) ID to Flask backend
Future<void> _addItemToPlaylist(String playlistName, String itemId, String itemType) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:5000/add_to_playlist'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'playlist_name': playlistName,
      'item_id': itemId,
      'item_type': itemType, // "movie" or "song"
    }),
  );

  if (response.statusCode == 200) {
    print('$itemType added to playlist!');
  } else {
    print('Failed to add $itemType to playlist.');
  }
}

// Function to fetch existing playlists from the backend
Future<List<String>> fetchExistingPlaylists() async {
  final response = await http.get(Uri.parse('http://127.0.0.1:5000/get_playlists'));

  if (response.statusCode == 200) {
    List<dynamic> playlists = json.decode(response.body);
    return playlists.map<String>((playlist) => playlist['name'] as String).toList();
  } else {
    print('Failed to fetch playlists.');
    return [];
  }
}