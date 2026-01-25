import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> listarUsuarios(Request request) async{
final params = request.url.queryParameters;

dynamic query = supabase
      .from('usuarios')
      .select('id, nome, login, email, senha, admin');

final camposValidos = [
    'id',
    'nome',
    'login',
    'email',
    'admin',
  ];

bool temFiltros = false;

for (var campo in camposValidos) {
  final valor = params[campo];

  if (valor == null || valor.isEmpty) continue;

  temFiltros = true;

  if (['id', 'admin'].contains(campo)) {
    query = query.eq(campo, valor);
  } 
  else {
    query = query.ilike(campo, '%$valor%');
  }
}

if (!temFiltros) {
    query = query
        .order('id', ascending: false)
        .limit(10);
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