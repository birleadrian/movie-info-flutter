import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:movie_info/movie.dart';

void main() {
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(primarySwatch: Colors.blue, scaffoldBackgroundColor: const Color(0xFF82B1FF)),
      home: const MoviePage(title: 'Movies'),
    );
  }
}

class MoviePage extends StatefulWidget {
  const MoviePage({super.key, required this.title});

  final String title;

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final PageController controller = PageController();
  static const String apiURL = 'https://yts.mx/api/v2/list_movies.json';
  bool isLoading = false;
  List<Movie> movies = <Movie>[];

  Future<void> _fetchMovies() async {
    setState(() {
      isLoading = true;
    });

    final Response response = await get(Uri.parse(apiURL));
    final Map<String, dynamic> responseBody = json.decode(response.body) as Map<String, dynamic>;
    final Map<String, dynamic> data = responseBody['data'] as Map<String, dynamic>;
    final List<Map<dynamic, dynamic>> responseMovies =
        List<Map<dynamic, dynamic>>.from(data['movies'] as List<dynamic>);

    for (final Map<dynamic, dynamic> item in responseMovies) {
      final String title = item['title'] as String;
      final int year = item['year'] as int;
      final int runtime = item['runtime'] as int;
      final String imageURL = item['medium_cover_image'] as String;
      final List<dynamic> tempGenres = item['genres'] as List<dynamic>;
      final List<String> genres = <String>[];
      for (final dynamic genre in tempGenres) {
        genres.add(genre as String);
      }
      final Movie newMovie = Movie(title, year, runtime, imageURL, genres);
      movies.add(newMovie);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: movies.length,
        itemBuilder: (BuildContext context, int index) {
          final Movie movie = movies[index];
          final StringBuffer sb = StringBuffer();
          for (final String genre in movie.genres) {
            sb.write('$genre / ');
          }
          String genres = sb.toString();
          genres = genres.substring(0, genres.length - 2);
          final int hours = (movie.runtime / 60).floor();
          final int minutes = movie.runtime - 60 * hours;
          String duration;
          if (minutes < 10) {
            duration = '$hours:0$minutes h';
          } else {
            duration = '$hours:$minutes h';
          }
          return Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Container(
                    height: 1.75 * MediaQuery.of(context).size.height / 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(movie.imageURL),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Roboto',
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    genres,
                    style: const TextStyle(color: Colors.white70, fontSize: 15, fontFamily: 'Roboto'),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    duration,
                    style: const TextStyle(color: Colors.white70, fontSize: 15, fontFamily: 'Roboto'),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Release year: ${movie.year.toString()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 25, fontFamily: 'Roboto'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
