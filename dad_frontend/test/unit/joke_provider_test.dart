import 'package:dad_frontend/joke_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'joke_provider_test.mocks.dart';


@GenerateMocks([http.Client])
void main (){

  group('Mocking fetchJoke', (){
    test('fetchJoke should return not null on 200', ()async {
      //Arrange
      final provider = JokeProvider();
      final mockClient = MockClient();

      //Act
      when(mockClient.get(any))
        .thenAnswer((_)async => http.Response(
          '{"id": "2342", "setup": "Setup", "punchline": "Punch"}', 
          200
        ));
      await provider.fetchJoke(mockClient);

      //Assert
      expect(provider.setup, "Setup");
      expect(provider.punchline, "Punch");
      expect(provider.error, null);
    });
    test('fetchJoke should not return null on other 200s', ()async {
      //Arrange
      final provider = JokeProvider();
      final mockClient = MockClient();

      //Act
      when(mockClient.get(any))
        .thenAnswer((_)async => http.Response(
          '{"id": "2342", "setup": "Setup", "punchline": "Punch"}', 
          203
        ));
      await provider.fetchJoke(mockClient);

      //Assert
      expect(provider.setup, "Setup");
      expect(provider.punchline, "Punch");
      expect(provider.error, null);
    });
    test('fetchJoke should return null on error 300', ()async {
      //Arrange
      final provider = JokeProvider();
      final mockClient = MockClient();

      //Act
      when(mockClient.get(any))
        .thenAnswer((_)async => http.Response(
          '{"id": "2342", "setup": "Setup", "punchline": "Punch"}', 
          300
        ));
      await provider.fetchJoke(mockClient);

      //Assert
      expect(provider.setup, null);
      expect(provider.punchline, null);
      expect(provider.error, isNotNull);
    });
    test('fetchJoke should return null on error 400', ()async {
      //Arrange
      final provider = JokeProvider();
      final mockClient = MockClient();

      //Act
      when(mockClient.get(any))
        .thenAnswer((_)async => http.Response(
          '{"id": "2342", "setup": "Setup", "punchline": "Punch"}', 
          400
        ));
      await provider.fetchJoke(mockClient);

      //Assert
      expect(provider.setup, null);
      expect(provider.punchline, null);
      expect(provider.error, isNotNull);
    });
    test('should handle network errors', () async {
      //Arrange
      final provider = JokeProvider();
      final mockClient = MockClient();
      //Act
      when(mockClient.get(any))
        .thenThrow(http.ClientException('Network error'));

      await provider.fetchJoke(mockClient);
      //Assert
      expect(provider.setup, isNull);
      expect(provider.punchline, isNull);
      expect(provider.error, contains('Network error'));
    });
    test('Invalid joke format', () async {
      //Arrange
      final provider = JokeProvider();
      final mockClient = MockClient();
      //Act
      when(mockClient.get(any))
        .thenAnswer((_)async => http.Response(
          '{"id": "2342", "punchline": "Punch"}', 
          200
        ));

      await provider.fetchJoke(mockClient);
      //Assert
      expect(provider.error, contains('FormatException'));
    });
  });
}