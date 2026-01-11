import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> deletarEntidade(Request request, String id) async {
  final result = await supabase
  .from('entidades')
  .select('id')
  .eq('id', int.parse(id))
  .limit(1);

  if (result.isEmpty) {
    return Response.notFound(
      jsonEncode({'erro': 'Entidade não encontrada.'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  try{
    await supabase
    .from('entidades')
    .delete()
    .eq('id', int.parse(id));
  }catch(e){
    final errorMsg = e.toString();
    return Response.internalServerError(
      body: jsonEncode({'erro': 'Erro ao deletar entidade: $errorMsg'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  return Response.ok(
    jsonEncode({'mensagem': 'Entidade excluída com sucesso.'}),
    headers: {'Content-Type': 'application/json'},
  );
}
