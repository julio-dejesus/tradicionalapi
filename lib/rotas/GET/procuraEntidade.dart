import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:tradicional/supabase_client.dart';

Future<Response> procuraEntidade(Request request) async {
  final params = request.url.queryParameters;

  if (params.isEmpty) {
    return Response.badRequest(
      body: 'A requisição deve conter pelo menos uma especificação',
    );
  }

  final camposValidos = [
    'id',
    'sigla',
    'nome',
    'fundado',
    'rt',
    'cidade',
    'endereco'
  ];

  var query = supabase
      .from('entidades')
      .select('id, sigla, nome, fundado, rt, cidade, endereco, verificado');

  bool temFiltros = false;

  for (var campo in camposValidos) {
    final valor = params[campo];

    if (valor == null || valor.isEmpty) continue;

    temFiltros = true;

    if (['id', 'rt'].contains(campo)) {
      query = query.eq(campo, valor);
    } else if (campo == 'fundado') {
      query = query.eq(campo, valor);
    } else {
      query = query.ilike(campo, '%$valor%');
    }
  }

  if (!temFiltros) {
    return Response.badRequest(
      body: 'A requisição deve conter pelo menos uma especificação',
    );
  }

  try {
    await supabase.rpc('atualiza_ultima_requisicao');
  } catch (e) {
    print('Erro RPC: $e');
  }

  final result = await query;

  return Response.ok(
    jsonEncode(result),
    headers: {'Content-Type': 'application/json'},
  );
}
