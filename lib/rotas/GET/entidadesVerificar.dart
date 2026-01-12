import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> entidadesVerificar(Request request) async{

  final result = await supabase
  .from('entidades')
  .select(
    'id, sigla, nome, fundado, rt, cidade, endereco, verificado')
    .eq('verificado', false);

  return Response.ok(
    jsonEncode(result),
    headers: {'Content-Type': 'application/json'},
  );

}