import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';
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
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        usuarios.add(item);
      } else {
        return Response.badRequest(body: 'A lista contém um item inválido.');
      }
    }
  } else {
    return Response.badRequest(body: 'Formato JSON inválido. Esperado objeto ou lista.');
  }

  final inseridos = [];
  final falhas = [];

  for (final usuario in usuarios) {
    final nome = usuario['nome'];
    final login = usuario['login'];
    final email = usuario['email'];
    final senha = usuario['senha'];


    // Validações
    if (nome == null ||
        nome.toString().isEmpty ||
        login == null ||
        login.toString().isEmpty ||
        senha == null ||
        senha.toString().isEmpty) {
      falhas.add({
        'usuario': usuario,
        'erro': 'Nome, login e senha são obrigatórios.'
      });
      continue;
    }

    try {
      final hash = BCrypt.hashpw(senha, BCrypt.gensalt());

      await supabase.from('usuarios').insert({
        'nome': nome,
        'login': login,
        'email': email,
        'senha': hash,
      });

      inseridos.add({
        'login': login,
         'nome': nome
      });


    }catch (e) {
  final errorMsg = e.toString();

  if (errorMsg.contains('23505') ||
      errorMsg.contains('duplicate key')) {
    falhas.add({
      'usuario': usuario,
      'erro': 'Login já está em uso. Escolha outro.',
    });
  } else {
    falhas.add({
      'usuario': usuario,
      'erro': 'Erro no banco de dados: $errorMsg',
    });
  }
    }
  }

  return Response.ok(
    jsonEncode({
      'sucesso': falhas.isEmpty,
      'inseridas': inseridos,
      'falhas': falhas,
      'summary': {
        'total': falhas.length,
        'inseridas': inseridos.length,
        'falhas': falhas.length,
      }
    }),
    headers: {'Content-Type': 'application/json'},
  );

}

