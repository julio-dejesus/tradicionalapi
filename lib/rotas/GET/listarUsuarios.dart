import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> listarUsuarios(Request request) async{

  await supabase.rpc("atualiza_ultima_requisicao");

  final result = await supabase
  .from('usuarios')
  .select('id, nome, login, email, senha, admin');

  return Response.ok(
    jsonEncode(result),
    headers: {'Content-Type': 'application/json'},
  );

}