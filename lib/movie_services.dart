import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Fetch movies by title
Future<List<Map<String, String>>> fetchMoviesByTitle(String title) async {
  var url = "http://127.0.0.1:5000/searchMovieByTitle?title=$title";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, String>>((movie) => {
              'title': movie['"title"'] ?? 'No Title Available',
              'description': movie['"description"'] ?? 'No Description Available',
              'image_url': movie['"image_url"'] ?? '',
              'line': movie['"line"'] ?? 'No line',
              'r_year': movie['"r_year"'] ?? 'Not released',
              'genre': (movie['"genre"'] ?? []).join(', ') ?? 'No genre',
              'cast': (movie["cast"] ?? []).join(', ') ?? 'No cast',
              'director': movie["director"] ?? 'No director',
            })
        .toList();
  } else {
    throw Exception('Failed to fetch movies by title: ${response.statusCode}');
  }
}

// Fetch movies by genre
Future<List<Map<String, String>>> fetchMoviesByGenre(String genre) async {
  var url = "http://127.0.0.1:5000/searchMovieByGenre?genre=$genre";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, String>>((movie) => {
              'title': movie['"title"'] ?? 'No Title Available',
              'description': movie['"description"'] ?? 'No Description Available',
              'image_url': movie['"image_url"'] ?? '',
              'line': movie['"line"'] ?? 'No line',
              'r_year': movie['"r_year"'] ?? 'Not released',
              'genre': (movie['"genre"'] ?? []).join(', ') ?? 'No genre',
              'cast': (movie["cast"] ?? []).join(', ') ?? 'No cast',
              'director': movie["director"] ?? 'No director',
            })
        .toList();
  } else {
    throw Exception('Failed to fetch movies by genre: ${response.statusCode}');
  }
}

Future<List<Map<String, String>>> fetchMoviesByActor(String actor) async {
  var url = "http://127.0.0.1:5000/searchMovieByActor?actor=$actor"; // Corrected endpoint
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, String>>((movie) => {
              'title': movie['"title"'] ?? 'No Title Available',
              'description': movie['"description"'] ?? 'No Description Available',
              'image_url': movie['"image_url"'] ?? '',
              'line': movie['"line"'] ?? 'No line',
              'r_year': movie['"r_year"'] ?? 'Not released',
              'genre': (movie['"genre"'] ?? []).join(', ') ?? 'No genre',
              'cast': (movie["cast"] ?? []).join(', ') ?? 'No cast',
              'director': movie["director"] ?? 'No director',
            })
        .toList();
  } else {
    throw Exception('Failed to fetch movies by actor: ${response.statusCode}');
  }
}

Future<List<Map<String, String>>> fetchAllMovies() async {
  var url = "http://127.0.0.1:5000/getAllMovies"; // Endpoint for all movies
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, String>>((movie) => {
              'title': movie['"title"'] ?? 'No Title Available',
              'description': movie['"description"'] ?? 'No Description Available',
              'image_url': movie['"image_url"'] ?? '',
              'line': movie['"line"'] ?? 'No line',
              'r_year': movie['"r_year"'] ?? 'Not released',
              'genre': (movie['"genre"'] ?? []).join(', ') ?? 'No genre',
              'cast': (movie["cast"] ?? []).join(', ') ?? 'No cast',
              'director': movie["director"] ?? 'No director',
            })
        .toList();
  } else {
    throw Exception('Failed to fetch all movies: ${response.statusCode}');
  }
}


// Show movie description popup
void showDescriptionPopup(BuildContext context, Map<String, dynamic> movie) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      double dynamicImageWidth = screenWidth * 0.45;
      double dynamicImageHeight = screenHeight * 0.3;

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
          child: SingleChildScrollView(
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
                                fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'Oswald'),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Director: ${movie['director']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Cast: ${movie['cast']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  constraints: BoxConstraints(maxWidth: screenWidth),
                  child: Text(
                    movie['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    '"${movie['line']}"',
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    },
  );
}
