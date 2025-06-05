import 'package:flutter_test/flutter_test.dart';
import 'package:dad_frontend/joke_provider.dart';


void main(){
  group('JokeProvider', (){
    test('error at beginning', (){
      //Arrange
      final joker = JokeProvider();
      //Act
      

      //Assert
      expect(joker.error, null);
    });
    test('punchline at beginning', (){
      //Arrange
      final joker = JokeProvider();
      //Act
      

      //Assert
      expect(joker.punchline, null);
    });
    test('setup at beginning', (){
      //Arrange
      final joker = JokeProvider();
      //Act
      

      //Assert
      expect(joker.setup, null);
    });
    test('isLoading at beginning', (){
      //Arrange
      final joker = JokeProvider();
      //Act
      

      //Assert
      expect(joker.isLoading, false);
    });
   
  });
}