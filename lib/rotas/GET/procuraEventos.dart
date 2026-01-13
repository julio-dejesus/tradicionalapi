import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> procuraEventos(Request request) async {
  final body = await request.readAsString();

  if(body.trim().isEmpty){
    return Response.badRequest(body: 'A requisição deve conter pelo menos uma especificação');
  }

  Map<String, dynamic> data;
  try{
    data = jsonDecode(body);
  }catch(e){
    return Response.badRequest(body: 'JSON inválido: ${e.toString()}');
  }

  // Não irá filtrar por "verificado" pois este tem uma classe específica.
  final camposValidos = ['id', 'organizador', 'dataRealizacao', 'tipoEvento', 'dataInscricao', 'cidade', 'endereco', 'premio', 'contato'];

  var query = supabase.from('eventos').
  select('id, organizador, data_realizacao, tipo_evento, data_inscricao, cidade, endereco, premio, contato, verificado');

  bool temFiltros = false;

  for (var campo in camposValidos) {
    if (data.containsKey(campo) && data[campo] != null && data[campo].toString().isNotEmpty) {
      temFiltros = true;
      }
      if (['id', 'data_realizacao', 'data_inscricao'].contains(campo)) {
        query = query.eq(campo, data[campo]);
      } else {
        query = query.ilike(campo, '%${data[campo]}%');
      }
    }

  if (!temFiltros) {
    return Response.badRequest(
      body: 'A requisição deve conter pelo menos uma especificação',
    );
  }

    try {
    await supabase.rpc('atualiza_ultima_requisicao');
  } catch (e, stack) {
    print('ERRO na RPC atualiza_ultima_requisicao: $e');
    print(stack);
  }

  final result = await query;

  return Response.ok(
    jsonEncode(result),
    headers: {'Content-Type': 'application/json'},
  );
}
