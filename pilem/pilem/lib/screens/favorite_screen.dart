import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/screens/detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {

  List<Movie> _favorites = [];

  void _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final Set<String> keys = prefs.getKeys();
    List<Movie> favorites = [];
    for (String key in keys) {
      if (key.startsWith('movie_')) {
        final String? movieJson = prefs.getString(key);
        if (movieJson != null) {
          Movie movie = Movie.fromJson(json.decode(movieJson));
          movie.isFavorite = true;
          favorites.add(movie);
        }
      }
    }
    setState(() {
      _favorites = favorites;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Movies')),
      body: _favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  // SizedBox(height: 16),
                  Text('Belum ada film favorit',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final Movie movie = _favorites[index];
                return ListTile(
                  leading: Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                    width: 50,
                    height: 75,
                    fit: BoxFit.cover,
                  ),
                  title: Text(movie.title),
                  subtitle: Text(movie.releaseDate),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(movie: movie),
                    ),
                  ).then((_) => _loadFavorites()),
                );
              },
            ),
    );
  }
}