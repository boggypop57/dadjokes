import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

class Database {
  static Connection? _connection;

  static Future<void> _initPostgre() async{
    final env = DotEnv()..load();
    final name = env['DBNAME'];
    final user = env['DBUSER'];
    final pass = env['DBPASS'];
    print('Environment loaded: $name, $user, $pass');
    try{
      if(name != null &&
         user != null &&
         pass != null){
      
        _connection = await Connection.open(
          Endpoint(
            host: 'localhost',
            database: name,
            username: user,
            password: pass,
          ),
          settings: const ConnectionSettings(
            sslMode: SslMode.disable,
          ),
        );
      } else {
        throw Exception('CustomException: name,'
        ' user or pass is null.');
      }
    } catch (e){
      print('$e');
    }
  }

  static Future<Connection> connection() async{
    if(_connection == null || !_connection!.isOpen){
      await _initPostgre();
    }
    return _connection!;
  }

  Future<void> close() async {
    if(_connection != null){
      if (_connection!.isOpen) {
        await _connection!.close();
      }
    }
  }
}
