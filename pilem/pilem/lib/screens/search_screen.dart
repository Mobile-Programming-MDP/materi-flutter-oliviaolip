import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/screens/detail_screen.dart';
import 'package:pilem/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];
  Set<int> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchMovies);
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchMovies() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    final List<Map<String, dynamic>> searchData =
        await _apiService.searchMovies(_searchController.text);
    setState(() {
      _searchResults = searchData.map((e) => Movie.fromJson(e)).toList();

      for (var movie in _searchResults) {
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

      for (var movie in _searchResults) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search movies...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _searchController.text.isNotEmpty,
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final Movie movie = _searchResults[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Image.network(
                        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(movie.title),
                      trailing: IconButton(
                        icon: Icon(
                          _favoriteIds.contains(movie.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _favoriteIds.contains(movie.id)
                              ? Colors.red
                              : null,
                        ),
                        onPressed: () => _toggleFavorite(movie),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(movie: movie),
                          ),
                        ).then((_) => _loadFavorites());
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}