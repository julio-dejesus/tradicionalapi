import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

final _chaveSecreta = 'chave_api_tradicional';

Middleware verificarJWTMiddleware() {

  // Lista de rotas que NÃO precisam de autenticação
  final rotasPublicas = {
    'logar',
    'cadastroEventos',
    'cadastroEntidades',
    'entidadesVerificar',
    'eventosVerificar',
    'listarEntidades',
    'listarEventos',
    'procuraEntidades',
    'procuraEventos',
  };

  return (Handler innerHandler) {
    return (Request request) async {
      final path = request.url.path;

      if (rotasPublicas.contains(path)) {
        return await innerHandler(request); // pula verificação
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
