import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../supabase_client.dart';

Future<Response> verificarEvento(Request request, String id) async {
  final idParam = request.params['id'];
  final id = int.tryParse(idParam ?? '');

  if (id == null) {
    return Response.badRequest(
      body: jsonEncode({'erro': 'ID inválido'}),
      headers: {'Content-Type': 'application/json'});
  }

  final result = await supabase
      .from('eventos')
      .select('id')
      .eq('id', id)
      .limit(1);

  if (result.isEmpty) {
    return Response.notFound(
      jsonEncode({'erro': 'Evento com ID $id não existe.'}),
      headers: {'Content-Type': 'application/json'});
  }

  try {
    await supabase
        .from('eventos')
        .update({'verificado': true})
        .eq('id', id);
  } catch (e) {
    final errorMsg = e.toString();
    return Response.internalServerError(body: 'Erro ao atualizar Supabase: $errorMsg');
  }

  return Response.ok(
    jsonEncode({'mensagem': 'Evento verificado com sucesso'}),
    headers: {'Content-Type': 'application/json'});

}
