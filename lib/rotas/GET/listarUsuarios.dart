import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> listarUsuarios(Request request) async{

    try {
    await supabase.rpc('atualiza_ultima_requisicao');
  } catch (e, stack) {
    print('ERRO na RPC atualiza_ultima_requisicao: $e');
    print(stack);
  }

  final result = await supabase
  .from('usuarios')
  .select('id, nome, login, email, senha, admin');

  return Response.ok(
    jsonEncode(result),
    headers: {'Content-Type': 'application/json'},
  );

}