import 'dart:developer';
import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

class Database {
  Database() {
    // Загружаем переменные окружения
    final env = DotEnv()..load();
    
    // Инициализируем параметры подключения
    _dbname = env['DBNAME'];
    _dbuser = env['DBUSER'];
    _dbpass = env['DBPASS'];
  }
  late final Connection _connection;
  late final String? _dbname;
  late final String? _dbuser;
  late final String? _dbpass;

  Future<void> initPostgre() async{
    try{
      if(_dbname != null &&
         _dbuser != null &&
         _dbpass != null){
      
        _connection = await Connection.open(
          Endpoint(
            host: 'localhost',
            database: _dbname!,
            username: _dbuser,
            password: _dbpass,
          ),
          settings: const ConnectionSettings(
            sslMode: SslMode.disable,
          ),
        );
      } else {
        throw Exception('CustomException: _dbname,'
        ' _dbuser or _dbpass is null.');
      }
    } catch (e){
      log('$e');
    }
  }

  Connection get connection => _connection;

  Future<void> close() async {
    if (_connection.isOpen) {
      await _connection.close();
    }
  }
}
