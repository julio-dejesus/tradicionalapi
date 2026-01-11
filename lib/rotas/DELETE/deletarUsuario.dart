import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> deletarUsuario(Request request, String id) async {
  final result = await supabase
  .from('usuarios')
  .select('id')
  .eq('id', int.parse(id))
  .limit(1);

  if (result.isEmpty) {
    return Response.notFound(
      jsonEncode({'erro': 'Usuário não encontrado.'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  try{
    await supabase
    .from('usuarios')
    .delete()
    .eq('id', int.parse(id));
  }catch(e){
    final errorMsg = e.toString();
    return Response.internalServerError(
      body: jsonEncode({'erro': 'Erro ao deletar usuário: $errorMsg'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  return Response.ok(
    jsonEncode({'mensagem': 'Usuário excluído com sucesso.'}),
    headers: {'Content-Type': 'application/json'},
  );
}
