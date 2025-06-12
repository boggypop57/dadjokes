import 'package:dad_backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context, String joker) async {
  try {
    if(joker == 'jokes'){
      switch(context.request.method){

        case HttpMethod.get:
          return fetchAllJokes(context);

        case HttpMethod.delete:
          return deleteAllJokes(context);

        // ignore: no_default_cases
        default:
          return Response(statusCode: 405);
      }
    }
    else if (joker == 'joke'){
      switch(context.request.method){

        case HttpMethod.post:
          return addJoke(context);

        case HttpMethod.delete:
          return deleteJoke(context);
      
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


Future<Response> deleteJoke(RequestContext context) async{
  final db = await Database.connection();
  final joke = await context.request.json() as Map<String, dynamic>;

  final sql = Sql.named('DELETE FROM joke WHERE setup ='
  ' @setup:text AND punchline = @punchline:text');
  await db.execute(
    sql,
    parameters: {
      'setup': joke['setup'] as String, 
      'punchline': joke['punchline'] as String,
    },
  );
  return Response.json(body: {'status': 'Joke is deleted'});
}


Future<Response> addJoke(RequestContext context) async{
  final db = await Database.connection();
  print('Joker joke post started');
  final joke = await context.request.json() as Map<String, dynamic>;
  print('body: $joke');
  if(joke['setup'] == null || joke['punchline'] == null){
    return Response(statusCode: 405, body: 'setup or punchline is null');
  }

  final sql = Sql.named('INSERT INTO joke (setup, punchline)'
  ' VALUES (@setup:text, @punchline:text)');
  await db.execute(
    sql,
    parameters: {
      'setup': joke['setup'] as String,
      'punchline': joke['punchline'] as String,
    },
  );
  return Response.json(body: {'status': 'added'});
}


Future<Response> fetchAllJokes(RequestContext context) async{
  final db = await Database.connection();
  print('Fetching jokes...');
  final jokes = await db.execute('SELECT * FROM joke');
  print('Jokes from DB: $jokes');
  return Response.json(body: jokes);
}


Future<Response> deleteAllJokes(RequestContext context) async{
  final db = await Database.connection();
  final result = await db.execute('TRUNCATE joke RESTART IDENTITY');
  return Response.json(body: {'result': result.toString()});
}
