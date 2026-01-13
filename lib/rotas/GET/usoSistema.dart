import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:tradicional/supabase_client.dart';

Future<Response> usoSistema(Request request) async {

  final result = await supabase
      .from('logs_sistema')
      .select('inclusao_entidade, inclusao_evento, validacao_entidade, validacao_evento, ultima_requisicao');

  return Response.ok(
    jsonEncode(result),
    headers: {'Content-Type': 'application/json'},
  );
}