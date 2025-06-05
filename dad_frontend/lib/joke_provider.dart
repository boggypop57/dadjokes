import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:provider/provider.dart';

class JokeProvider extends ChangeNotifier{
  String? setup; //The main part of a joke
  String? punchline;
  String? error;
  bool isLoading = false;

  Future<void> fetchJoke(http.Client? client) async {
    final usedClient = client ?? http.Client();

    try {
      isLoading = true;
      notifyListeners();

      final response = await usedClient.get(
        Uri.parse('http://localhost:8080/'),
      );

      if(response.statusCode >= 200 && response.statusCode <= 299){
        final stringBody = response.body;
        final data = JsonDecoder().convert(stringBody) as Map<String, dynamic>;
        if (!data.containsKey('setup') || !data.containsKey('punchline')) {
          throw FormatException('Invalid joke format');
        }
        setup = data['setup'];
        punchline = data['punchline'];
        error = null;
      }
      else{
        setup = null;
        punchline = null;
        error = 'Failed to load joke: ${response.statusCode}';
      }
  
      notifyListeners();
    } catch (e) {
      error = e.toString();
    } finally{
      isLoading = false;
      notifyListeners();
    }
  }
}