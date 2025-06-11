import 'package:dad_backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';


Handler middleware(Handler handler) {
 
  return handler.use(provider<Database>((_) => Database()));
}
