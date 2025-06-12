import 'package:dad_backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String joker) async {
  try {
    final db = await Database.connection();
  
    if(joker == 'jokes'){
      switch(context.request.method){
        case HttpMethod.get:

          print('Fetching jokes...');
          final jokes = await db.execute('SELECT * FROM joke');
          print('Jokes from DB: $jokes');
          return Response.json(body: {'jokes': jokes});
        
        case HttpMethod.post:
          final body = await context.request.json() as Map<String, dynamic>;
          final jokes = body['jokes'] as List<dynamic>;
          for (final jokeData in jokes){
            final joke = jokeData as Map<String, dynamic>;
            await db.execute(
              'INSERT INTO joke (setup, punchline) VALUES (@setup, @punchline)',
              parameters: [joke['setup'] as String, joke['punchline'] as String],
            );
          }
          return Response.json(body: {'status': 'added'});
      
        // ignore: no_default_cases
        default:
          return Response(statusCode: 405);
      }
    }
    else if (joker == 'joke'){
      switch(context.request.method){
        case HttpMethod.post:

          print('Joker joke post started');
          final joke = await context.request.json() as Map<String, dynamic>;
          print('body: $joke');
          await db.execute(
            'INSERT INTO joke (setup, punchline) VALUES (@setup, @punchline)',
            parameters: [joke['setup'] as String, joke['punchline'] as String],
          );
          return Response.json(body: {'status': 'added'});

        case HttpMethod.delete:
          final joke = await context.request.json() as Map<String, dynamic>;
          await db.execute(
            'DELETE FROM joke WHERE setup = @setup AND punchline = @punchline',
            parameters: [joke['setup'], joke['punchline']],
          );
          return Response.json(body: {'status': 'Joke is deleted'});
      
        // ignore: no_default_cases
        default:
          print('This is default');
          return Response(statusCode: 405, body: 'pum pum pum');
      }
    } else{
      return Response.json(body: {'status': 'Invalid path "$joker"'});
    }   

  } catch (e) {
    print('db/[joker].dart: $e');
    return Response(statusCode: 405);
  }
}
