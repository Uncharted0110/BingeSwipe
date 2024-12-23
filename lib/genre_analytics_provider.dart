import 'package:flutter/material.dart';

class GenreAnalyticsProvider extends ChangeNotifier {
  final Map<String, int> _movieGenreFrequency = {};
  final Map<String, int> _songGenreFrequency = {};
  int _totalMoviesLiked = 0;
  int _totalSongsLiked = 0;

  Map<String, int> get movieGenreFrequency => _movieGenreFrequency;
  Map<String, int> get songGenreFrequency => _songGenreFrequency;
  int get totalMoviesLiked => _totalMoviesLiked;
  int get totalSongsLiked => _totalSongsLiked;

  // Method to add movie genres and update the count
  void addMovieGenres(List<String> genres) {
    for (var genre in genres) {
      _movieGenreFrequency[genre] = (_movieGenreFrequency[genre] ?? 0) + 1;
    }
    _totalMoviesLiked += 1;  // Increment by number of genres added
    notifyListeners();
  }

  // Method to add song genres and update the count
  void addSongGenres(List<String> genres) {
    for (var genre in genres) {
      _songGenreFrequency[genre] = (_songGenreFrequency[genre] ?? 0) + 1;
    }
    _totalSongsLiked += 1;  // Increment by number of genres added
    notifyListeners();
  }

  // Method to reset all the analytics data
  void resetAnalytics() {
    _movieGenreFrequency.clear();
    _songGenreFrequency.clear();
    _totalMoviesLiked = 0;
    _totalSongsLiked = 0;
    notifyListeners();
  }
}
