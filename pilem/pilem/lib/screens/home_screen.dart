import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/screens/detail_screen.dart';
import 'package:pilem/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  List<Movie> _allMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];
  Set<int> _favoriteIds = {};

  Future<void> _loadMovies() async {
    final List<Map<String, dynamic>> allMoviesData =
        await _apiService.getAllMovies();
    final List<Map<String, dynamic>> trendingMoviesData =
        await _apiService.getTrendingMovies();
    final List<Map<String, dynamic>> popularMoviesData =
        await _apiService.getPopularMovies();

    setState(() {
      _allMovies = allMoviesData.map((json) => Movie.fromJson(json)).toList();
      _trendingMovies =
          trendingMoviesData.map((json) => Movie.fromJson(json)).toList();
      _popularMovies =
          popularMoviesData.map((json) => Movie.fromJson(json)).toList();

      // Apply favorite status from persisted favorites
      for (var movie in [..._allMovies, ..._trendingMovies, ..._popularMovies]) {
        movie.isFavorite = _favoriteIds.contains(movie.id);
      }
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final favIds = <int>{};

    for (final key in keys) {
      if (key.startsWith('movie_')) {
        final idString = key.replaceFirst('movie_', '');
        final id = int.tryParse(idString);
        if (id != null) favIds.add(id);
      }
    }

    setState(() {
      _favoriteIds = favIds;

      // Keep movie list favorite flags in sync
      for (var movie in [..._allMovies, ..._trendingMovies, ..._popularMovies]) {
        movie.isFavorite = _favoriteIds.contains(movie.id);
      }
    });
  }

  Future<void> _toggleFavorite(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'movie_${movie.id}';
    final isFav = _favoriteIds.contains(movie.id);

    setState(() {
      if (isFav) {
        _favoriteIds.remove(movie.id);
      } else {
        _favoriteIds.add(movie.id);
      }
      movie.isFavorite = !isFav;
    });

    if (isFav) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, json.encode(movie.toJson()));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites().then((_) => _loadMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilem"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoviesList("All Movies", _allMovies),
            _buildMoviesList("Trending Movies", _trendingMovies),
            _buildMoviesList("Popular Movies", _popularMovies),
          ],
        ),
      ),
    );
  }

  Widget _buildMoviesList(String title, List<Movie> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Menampilkan Title Kategori Movies
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        //Menapilkan thumnail dan judul movies
        SizedBox(
          height: 200,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              itemBuilder: (BuildContext build, int index) {
                final Movie movie = movies[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(movie: movie),
                    ),
                  ).then((_) => _loadFavorites()),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Image.network(
                              "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                iconSize: 20,
                                onPressed: () => _toggleFavorite(movie),
                                icon: Icon(
                                  _favoriteIds.contains(movie.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _favoriteIds.contains(movie.id)
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.title.length > 14
                              ? '${movie.title.substring(0, 10)}...'
                              : movie.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        )
      ],
    );
  }
}