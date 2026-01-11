import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> logar(Request request) async {
  final body = await request.readAsString();
  dynamic data;

  try {
    data = jsonDecode(body);
  } catch (e) {
    return Response.badRequest(
      body: 'JSON inválido: ${e.toString()}',
    );
  }

  final login = data['login'];
  final senha = data['senha'];

  if (login == null ||
      login.toString().isEmpty ||
      senha.toString().isEmpty ||
      senha == null) {
    return Response.badRequest(
      body: 'Campos "login" e "senha" são obrigatórios.',
    );
  }

  final result = await supabase
      .from('usuarios')
      .select('id, nome, email, login, senha, admin')
      .eq('login', login)
      .limit(1);

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
      'exp': DateTime.now().add(Duration(hours: 3)).millisecondsSinceEpoch ~/ 1000,
    },
    issuer: 'minha_api',
  );

  final token = jwt.sign(SecretKey('chave_api_tradicional'));

  return Response.ok(
    jsonEncode({'token': token}),
    headers: {'Content-Type': 'application/json'},
  );
}
