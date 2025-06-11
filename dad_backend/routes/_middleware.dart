import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    // Обрабатываем OPTIONS-запрос для CORS
    if (context.request.method == HttpMethod.options) {
      return Response(
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      );
    }

    // Пропускаем запрос через остальные обработчики
    final response = await handler(context);

    // Добавляем CORS-заголовки к основному ответу
    return response.copyWith(
      headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, DELETE',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
    );
  };
}
