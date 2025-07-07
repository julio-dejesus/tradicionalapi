import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../database.dart';

Future<Response> verificarEvento(Request request, String id) async {

  // Lê e valida o corpo da requisição
  final body = await request.readAsString();
  final data = jsonDecode(body);

  if (data['verificado'] != 'ok') {
    return Response.badRequest(body: jsonEncode({'erro': 'Corpo inválido. Esperado: {"verificado":"ok"}'}));
  }

  // Realiza o UPDATE
  final stmt = db.prepare('UPDATE Eventos SET verificado = 1 WHERE id = ?');
  stmt.execute([id]);
  final changes = db.getUpdatedRows();
  stmt.dispose();

  if (changes == 0) {
    return Response.notFound(jsonEncode({'erro': 'Evento não encontrado'}));
  }

  return Response.ok(jsonEncode({'mensagem': 'Evento verificado com sucesso'}));
}
