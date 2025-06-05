import 'package:dad_backend/services/dadjoke_api.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  try{
    final jokeProvider = JokeProvider();
    await jokeProvider.fetchJoke(http.Client());

    if (jokeProvider.error != null){
      return Response.json(
        body: {'error': jokeProvider.error},
        statusCode: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
        },
      );
    }
    return Response.json(
      body: jokeProvider.data,
      headers: {
        'Access-Control-Allow-Origin': '*',
      },
    );

  } catch (e){
    return Response.json(
      body: {'Internal server error': e.toString()},
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin': '*',
      },
    );
  }
}
