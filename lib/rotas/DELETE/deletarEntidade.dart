import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../database.dart';

Future<Response> deletarEntidade(Request request, String id) async {
  final stmt = db.prepare('DELETE FROM Entidades WHERE id = ?');
  stmt.execute([id]);
  final changes = db.getUpdatedRows();
  stmt.dispose();

  if (changes == 0) {
    return Response.notFound(
      jsonEncode({'erro': 'Entidade não encontrada.'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  return Response.ok(
    jsonEncode({'mensagem': 'Entidade excluída com sucesso.'}),
    headers: {'Content-Type': 'application/json'},
  );
}
