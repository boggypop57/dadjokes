// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:http/http.dart' as http;


class JokeProvider{
  Map<String, dynamic>? data;
  String? error;
  bool isLoading = false;

  Future<void> fetchJoke(http.Client? client) async {
    final usedClient = client ?? http.Client();

    try {
      isLoading = true;

      final response = await usedClient.get(
        Uri.parse('https://jokefather.com/api/jokes/random'),
      );

      if(response.statusCode >= 200 && response.statusCode <= 299){
        final stringBody = response.body;
        data = const JsonDecoder().convert(stringBody)
         as Map<String, dynamic>;
        if (!data!.containsKey('setup') || !data!.containsKey('punchline')) {
          throw const FormatException('Invalid joke format');
        }
        error = null;
      }
      else{
        data = null;
        error = 'Failed to load joke: ${response.statusCode}';
      }
    } catch (e) {
      error = e.toString();
    } finally{
      isLoading = false;
    }
  }
}
