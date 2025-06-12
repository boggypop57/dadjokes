import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JokeProvider extends ChangeNotifier {
  String? setup; //The main part of a joke
  String? punchline;
  String? error;
  bool isLoading = false;

  Future<void> fetchJoke() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('http://localhost:8080/'),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final stringBody = response.body;
        final data = JsonDecoder().convert(stringBody) as Map<String, dynamic>;
        if (!data.containsKey('setup') || !data.containsKey('punchline')) {
          throw FormatException('Invalid joke format');
        }
        setup = data['setup'];
        punchline = data['punchline'];
        error = null;

      } else {
        setup = null;
        punchline = null;
        error = 'Failed to load joke: ${response.statusCode}';
      }

      notifyListeners();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class JokesGallaryProvider extends ChangeNotifier {
  List<Joke> _jokes = [];
  bool isLoading = false;

  List<Joke> get jokes => _jokes;

  Future<void> fetchSavedGallary() async{
    try{
      isLoading = true;
      notifyListeners();
      final jokes = await _fetchJokesFromDB();
      debugPrint("joke_provider.dart, JokesGallaryProvider,"
    " fetchSavedGallary, jokes: $jokes");
      _jokes = jokes!;
      debugPrint("joke_provider.dart, JokesGallaryProvider,"
    " fetchSavedGallary, _jokes: $_jokes");
      isLoading = false;
      notifyListeners();
    } catch (e){
      debugPrint("joke_provider.dart, JokesGallaryProvider, fetchSavedGallary: $e");
    }
  }

  Future<void> addJoke(String setup, String punchline) async{
    try {
      final bool isSame = _jokes.any(
        (joke) => joke.setup == setup && joke.punchline == punchline,
      );
      if (isSame) return;
      _jokes.add(Joke(setup, punchline));
      notifyListeners();
      await _storeOneJokeInDB(Joke(setup, punchline));
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> deleteJoke(int index) async{
    final deleted = _jokes.removeAt(index);
    notifyListeners();
    await _deleteJokeFromDB(deleted);
  }

  Future<void> deleteAllJokes() async{
    debugPrint('Deleting everything...');
    await _deleteAllJokesFromDB();
    fetchSavedGallary();
    debugPrint('Should be deleted');
  }
}

class Joke {
  String setup;
  String punchline;

  Joke(this.setup, this.punchline);

  Map<String, dynamic> toJson() => {
    'setup': setup,
    'punchline': punchline
  };
}

class PreviousJokesProvider extends ChangeNotifier {
  final List<Joke> _jokes = []; 

  List<Joke> get jokes => _jokes;

  void scrollJokes(String setup, String punchline) {
    try {
      _jokes.insert(0, Joke(setup, punchline));
      if (_jokes.length == 4) _jokes.removeAt(3);
      notifyListeners();
    } catch (e) {
      debugPrint('$e');
    }
  }
}


// // other API
// Future<void> storeJokesInDB(List<Joke> jokes) async {
//   try {
//     await http.post(
//       Uri.parse('http://localhost:8080/db/jokes'),
//       headers: {'Content-Type' : 'application/json'},
//       body: jsonEncode({'jokes': jokes.map((j)=>j.toJson()).toList}),
//     );
//   } catch (e) {
//     debugPrint('joke_provider, storeJokesInDB: $e');
//   }
// }

Future<void> _storeOneJokeInDB(Joke joke) async{
  try {

    await http.post(
      Uri.parse('http://localhost:8080/db/joke'),
      headers: {'Content-Type' : 'application/json'},
      body: jsonEncode(joke.toJson()),
    );

  } catch (e) {
    debugPrint('joke_provider, storeOneJokeInDB: $e');
  }
}

Future<List<Joke>?> _fetchJokesFromDB () async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:8080/db/jokes')
    );

    if (response.statusCode != 200) {
      debugPrint('Request failed with status: ${response.statusCode}');
      return null;
    }

    final jokeList = jsonDecode(response.body) as List<dynamic>;

    return jokeList.map((joke) {
      final j = joke as List<dynamic>;
      return Joke(j[1] as String, j[2] as String);
    }).toList();

  } catch (e) {
    debugPrint('joke_provider, fetchJokesFromDB, error: $e');
    return null;
  } 
}

Future<void> _deleteJokeFromDB (Joke joke) async{ 
  try{
    await http.delete(
      Uri.parse('http://localhost:8080/db/joke'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(joke.toJson()),
    );
  } catch(e){
    debugPrint('joke_provider, deleteJokeFromDB: $e');
  }
}

Future<void> _deleteAllJokesFromDB () async {
  try{
    await http.delete(
      Uri.parse('http://localhost:8080/db/jokes'),
    );
  } catch (e){
    debugPrint('joke_provider, deleteAllJokesFromDB: $e');
  }
}