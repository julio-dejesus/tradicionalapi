import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

final _chaveSecreta = 'chave_api_tradicional';

Middleware verificarJWTMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final tentativeResponse = await innerHandler(request);

      if (tentativeResponse.statusCode == 404) {
        return tentativeResponse;
      }

      final authorization = request.headers['Authorization'];

      if (authorization == null || !authorization.startsWith('Bearer ')) {
        return Response.forbidden('Token não fornecido');
      }

      final token = authorization.substring(7);

      try {
        final jwt = JWT.verify(token, SecretKey(_chaveSecreta));
        final novoRequest = request.change(context: {'jwt': jwt});
        return await innerHandler(novoRequest);
      } catch (e) {
        if (e is JWTException) {
          if (e.message.toLowerCase().contains('expired')) {
            return Response.forbidden('Token expirado');
          }
          return Response.forbidden('Token inválido: ${e.message}');
        }

        return Response.internalServerError(body: 'Erro interno: ${e.toString()}');
      }
    };
  };
}
