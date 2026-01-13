import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> procuraEntidade(Request request) async {
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
  final camposValidos = ['id', 'sigla', 'nome', 'fundado', 'rt', 'cidade', 'endereco'];

  var query = supabase.from('entidades').select('id, sigla, nome, fundado, rt, cidade, endereco, verificado');
  
  bool temFiltros = false;

  for (var campo in camposValidos) {
  if (!data.containsKey(campo) ||
      data[campo] == null ||
      data[campo].toString().isEmpty) {
    continue;
  }

  temFiltros = true;

  if (['id', 'rt'].contains(campo)) {
    query = query.eq(campo, data[campo]);
  } else if (campo == 'fundado') {
    query = query.eq(campo, data[campo]); // se for date exata
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

  try {
    final result = await query;
  } catch (e, stack) {
    print('ERRO na requisição: $e');
    print(stack);
  }

  return Response.ok(
    jsonEncode(result),
    headers: {'Content-Type': 'application/json'},
  );
}
