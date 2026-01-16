import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> procuraEventos(Request request) async {
  final body = await request.readAsString();

  if (body.trim().isEmpty) {
    return Response.badRequest(
      body: 'A requisição deve conter pelo menos uma especificação',
    );
  }

  Map<String, dynamic> data;
  try {
    data = jsonDecode(body);
  } catch (e) {
    return Response.badRequest(
      body: 'JSON inválido: ${e.toString()}',
    );
  }

  final campos = {
    'id': 'id',
    'organizador': 'organizador',
    'dataRealizacao': 'data_realizacao',
    'tipoEvento': 'tipo_evento',
    'dataInscricao': 'data_inscricao',
    'cidade': 'cidade',
    'endereco': 'endereco',
    'premio': 'premio',
    'contato': 'contato',
  };

  var query = supabase.from('eventos').select(
    'id, organizador, data_realizacao, tipo_evento, data_inscricao, cidade, endereco, premio, contato, verificado',
  );

  bool temFiltros = false;

  for (final entry in campos.entries) {
    final campoJson = entry.key;
    final campoDb = entry.value;

    if (!data.containsKey(campoJson) ||
        data[campoJson] == null ||
        data[campoJson].toString().trim().isEmpty) {
      continue;
    }

    temFiltros = true;
    final valor = data[campoJson];

    if (campoDb == 'id') {
      query = query.eq(campoDb, valor);
      continue;
    }

    if (campoDb == 'data_realizacao' || campoDb == 'data_inscricao') {
      query = query.eq(campoDb, valor);
      continue;
    }

    query = query.ilike(campoDb, '%$valor%');
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

  try {
    final result = await query;

    return Response.ok(
      jsonEncode(result),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e, stack) {
    print('ERRO na requisição: $e');
    print(stack);

    return Response.internalServerError(
      body: 'Erro ao processar a requisição',
    );
  }
}
