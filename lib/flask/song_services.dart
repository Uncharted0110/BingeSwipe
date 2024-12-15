import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, String>>> fetchAllSongs() async {
  var url = "http://127.0.0.1:5000/getAllSongs"; // Endpoint for all movies
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, String>>((song) => {
              'title': song["song"] ?? 'No Title Available',
              'description': "" ?? 'No Description Available',
              'image_url': song["image_url"] ?? '',
              'line': "" ?? 'No line',
              'r_year': song["r_year"] ?? 'Not released',
              'genre': (song["genre"] ?? []).join(', ') ?? 'No genre',
              'cast': (song["artists"] ?? []).join(', ') ?? 'No cast',
              'director': "" ?? 'No director',
              'movie_id' : song["song_id"].toString(),
              'language': song["album"]
            })
        .toList();
  } else {
    throw Exception('Failed to fetch all song: ${response.statusCode}');
  }
}

// Fetch movies by title
Future<List<Map<String, String>>> fetchSongsByTrack(String name) async {
  var url = "http://127.0.0.1:5000/searchSongByTrack?name=$name";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, String>>((song) => {
              'title': song["song"] ?? 'No vailable',
              'description': "" ,
              'image_url': song["image_url"] ?? '',
              'line': "" ,
              'r_year': song["r_year"] ?? 'Not released',
              'genre': (song["genre"] ?? []).join(', ') ?? 'No genre',
              'cast': (song["artists"] ?? []).join(', ') ?? 'No cast',
              'director': "" ,
              'movie_id' : song["song_id"].toString(),
              'language': song["album"]
            })
        .toList();
  } else {
    throw Exception('Failed to fetch song by name: ${response.statusCode}');
  }
}

Future<List<Map<String, String>>> fetchSongsByArtist(String artist) async {
  var url = "http://127.0.0.1:5000//searchSongByArtist?artist=$artist"; // Corrected endpoint
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, String>>((song) => {
              'title': song["song"] ?? 'No vailable',
              'description': "" ,
              'image_url': song["image_url"] ?? '',
              'line': "" ,
              'r_year': song["r_year"] ?? 'Not released',
              'genre': (song["genre"] ?? []).join(', ') ?? 'No genre',
              'cast': (song["artists"] ?? []).join(', ') ?? 'No cast',
              'director': "" ,
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
              'title': song["song"] ?? 'No vailable',
              'description': "" ,
              'image_url': song["image_url"] ?? '',
              'line': "" ,
              'r_year': song["r_year"] ?? 'Not released',
              'genre': (song["genre"] ?? []).join(', ') ?? 'No genre',
              'cast': (song["artists"] ?? []).join(', ') ?? 'No cast',
              'director': "" ,
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
              'title': song["song"] ?? 'No vailable',
              'description': "" ,
              'image_url': song["image_url"] ?? '',
              'line': "" ,
              'r_year': song["r_year"] ?? 'Not released',
              'genre': (song["genre"] ?? []).join(', ') ?? 'No genre',
              'cast': (song["artists"] ?? []).join(', ') ?? 'No cast',
              'director': "" ,
              'movie_id' : song["song_id"].toString(),
              'language': song["album"]
            })
        .toList();
  } else {
    throw Exception('Failed to fetch song by genre: ${response.statusCode}');
  }
}