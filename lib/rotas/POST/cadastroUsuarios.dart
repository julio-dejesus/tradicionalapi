import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/common.dart';
import '../../database.dart';
import 'package:bcrypt/bcrypt.dart';

Future<Response> cadastroUsuarios(Request request) async {
  final body = await request.readAsString();

  dynamic data;
  try {
    data = jsonDecode(body);
  } catch (e) {
    return Response.badRequest(body: 'JSON inválido.');
  }

  List<Map<String, dynamic>> usuarios = [];

  if (data is Map<String, dynamic>) {
    usuarios.add(data);
  } else if (data is List) {
    for (var item in data) {
      if (item is Map<String, dynamic>) {
        usuarios.add(item);
      } else {
        return Response.badRequest(body: 'A lista contém um item inválido.');
      }
    }
  } else {
    return Response.badRequest(body: 'Formato JSON inválido. Esperado objeto ou lista de objetos.');
  }

  final inseridos = [];
  final falhas = [];

  for (final usuario in usuarios) {
    final nome = usuario['nome'];
    final login = usuario['login'];
    final email = usuario['email'];
    final senha = usuario['senha'];

    // Validações
    if (nome == null || nome == '' ||
        login == null || login == '' ||
        senha == null || senha == '') {
      falhas.add({
        'usuario': usuario,
        'erro': 'Nome, login e senha são obrigatórios.'
      });
      continue;
    }

    try {
      final hash = BCrypt.hashpw(senha, BCrypt.gensalt());

      final stmt = db.prepare(
          'INSERT INTO Usuarios (nome, login, email, senha) VALUES (?, ?, ?, ?)'
      );

      stmt.execute([nome, login, email, hash]);
      stmt.dispose();

      inseridos.add({'login': login, 'nome': nome});
    } on SqliteException catch (e) {
      if (e.message.contains('UNIQUE')) {
        falhas.add({
          'usuario': usuario,
          'erro': 'Login já está em uso. Escolha outro.'
        });
      } else {
        falhas.add({
          'usuario': usuario,
          'erro': 'Erro no banco de dados: ${e.message}'
        });
      }
    } catch (e) {
      falhas.add({
        'usuario': usuario,
        'erro': 'Erro inesperado: ${e.toString()}'
      });
    }
  }

  return Response.ok(
    jsonEncode({
      'sucesso': inseridos,
      'falhas': falhas,
    }),
    headers: {'Content-Type': 'application/json'},
  );
}
