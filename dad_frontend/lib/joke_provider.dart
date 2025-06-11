import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:provider/provider.dart';

class JokeProvider extends ChangeNotifier {
  String? setup; //The main part of a joke
  String? punchline;
  String? error;
  bool isLoading = false;

  Future<void> fetchJoke({http.Client? client}) async {
    final usedClient = client ?? http.Client();

    try {
      isLoading = true;
      notifyListeners();

      final response = await usedClient.get(
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

  List<Joke> get jokes => _jokes;

  void fetchSavedGallary() async{
    try{
      _jokes = await fetchJokesFromDB() ?? [];

    } catch (e){
      debugPrint("joke_provider.dart, JokesGallaryProvider, fetchSavedGallary: $e");
    }
  }

  void addJoke(String setup, String punchline) {
    try {
      final bool isSame = _jokes.any(
        (joke) => joke.setup == setup && joke.punchline == punchline,
      );
      if (isSame) return;
      _jokes.add(Joke(setup, punchline));
      notifyListeners();
      storeOneJokeInDB(Joke(setup, punchline));
    } catch (e) {
      debugPrint('$e');
    }
  }

  void deleteJoke(int index) {
    final deleted = _jokes.removeAt(index);
    notifyListeners();
    deleteJokeFromDB(deleted);
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

Future<void> storeOneJokeInDB(Joke joke) async{
  try {
    debugPrint('joke_provider, storeOneJokeInDB: Started function');
    debugPrint('joke_provider, storeOneJokeInDB: ${joke.toJson()}');

    final response = await http.post(
      Uri.parse('http://localhost:8080/db/joke'),
      headers: {'Content-Type' : 'application/json'},
      body: jsonEncode({'jokes': joke.toJson()}),
    );
    debugPrint('joke_provider, storeOneJokeInDB, response.statusCode: ${response.statusCode}');
    debugPrint('joke_provider, storeOneJokeInDB, response.body: ${response.body}');
  } catch (e) {
    debugPrint('joke_provider, storeOneJokeInDB: $e');
  }
}

Future<List<Joke>?> fetchJokesFromDB () async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:8080/db/jokes')
    );
    debugPrint('joke_provider, fetchJokesFromDB, response.statusCode: ${response.statusCode}');
    debugPrint('joke_provider, fetchJokesFromDB, response.body: ${response.body}');

    if (response.statusCode != 200) {
      debugPrint('Request failed with status: ${response.statusCode}');
      return null;
    }

    final data = JsonDecoder().convert(response.body) as Map<String, dynamic>;
    debugPrint('joke_provider, fetchJokesFromDB, data[\'jokes\']: ${data['jokes']}');

    final jokeList = data['jokes'] as List<dynamic>;

    return jokeList.map((j) {
      final jokeData = j as Map<String, dynamic>;
      return Joke(jokeData['setup'] as String, jokeData['punchline'] as String);
    }).toList();

  } catch (e) {
    debugPrint('joke_provider, fetchJokesFromDB, error: $e');
    return null;
  } 
}

Future<void> deleteJokeFromDB (Joke joke) async{
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