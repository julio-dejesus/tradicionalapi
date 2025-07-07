import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../database.dart';

Future<Response> deletarUsuario(Request request, String id) async {
  final stmt = db.prepare('DELETE FROM Usuarios WHERE id = ?');
  stmt.execute([id]);
  final changes = db.getUpdatedRows();
  stmt.dispose();

  if (changes == 0) {
    return Response.notFound(
      jsonEncode({'erro': 'Usuário não encontrado.'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  return Response.ok(
    jsonEncode({'mensagem': 'Usuário excluído com sucesso.'}),
    headers: {'Content-Type': 'application/json'},
  );
}
