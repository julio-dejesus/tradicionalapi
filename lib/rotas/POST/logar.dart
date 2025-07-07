import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import '../../database.dart';

Future<Response> logar(Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body);

  final login = data['login'];
  final senha = data['senha'];

  final stmt = db.prepare('SELECT * FROM Usuarios WHERE login = ?');
  final result = stmt.select([login]);
  stmt.dispose();

  if (result.isEmpty) {
    return Response.forbidden(jsonEncode({'erro': 'Login inválido'}));
  }

  final usuario = result.first;

  final senhaCorreta = BCrypt.checkpw(senha, usuario['senha']);

  if (!senhaCorreta) {
    return Response.forbidden(jsonEncode({'erro': 'Senha inválida'}));
  }

  // 🔐 Gera token JWT
  final jwt = JWT(
    {
      'id': usuario['id'],
      'nome': usuario['nome'],
      'email': usuario['email'],
      'login': usuario['login'],
      'admin': usuario['admin'],
      'exp': DateTime.now().add(Duration(minutes: 30)).millisecondsSinceEpoch ~/ 1000,
    },
    issuer: 'minha_api',
  );

  final token = jwt.sign(SecretKey('minha_chave_secreta'));

  return Response.ok(
    jsonEncode({'token': token}),
    headers: {'Content-Type': 'application/json'},
  );
}
