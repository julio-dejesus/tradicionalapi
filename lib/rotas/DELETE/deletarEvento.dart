import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../database.dart';

Future<Response> deletarEvento(Request request, String id) async {
  final stmt = db.prepare('DELETE FROM Eventos WHERE id = ?');
  stmt.execute([id]);
  final changes = db.getUpdatedRows();
  stmt.dispose();

  if (changes == 0) {
    return Response.notFound(
      jsonEncode({'erro': 'Evento não encontrado.'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  return Response.ok(
    jsonEncode({'mensagem': 'Evento excluído com sucesso.'}),
    headers: {'Content-Type': 'application/json'},
  );
}
