import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart'; // necessário para usar request.params
import '../../database.dart';

Future<Response> verificarEntidade(Request request) async {
  final id = request.params['id'];

  if (id == null) {
    return Response.badRequest(body: 'ID não fornecido');
  }

  final body = await request.readAsString();

  if (body.trim().isEmpty) {
    return Response.badRequest(body: 'A requisição deve conter pelo menos uma especificação');
  }

  dynamic data;
  try {
    data = jsonDecode(body);
  } catch (e) {
    return Response.badRequest(body: 'JSON inválido: ${e.toString()}');
  }

  if (data['verificado'] != 'ok') {
    return Response.badRequest(body: jsonEncode({'erro': 'Corpo inválido. Esperado: {"verificado":"ok"}'}));
  }

  final stmt = db.prepare('UPDATE Entidades SET verificado = 1 WHERE id = ?');
  stmt.execute([id]);
  final changes = db.getUpdatedRows();
  stmt.dispose();

  if (changes == 0) {
    return Response.notFound(jsonEncode({'erro': 'Entidade não encontrada'}));
  }

  return Response.ok(jsonEncode({'mensagem': 'Entidade verificada com sucesso'}));
}
