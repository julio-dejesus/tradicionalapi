import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> listarEventos(Request request) async{

  final result = await supabase
  .from('eventos')
  .select('id, organizador, data_realizacao, tipo_evento, data_inscricao, cidade, endereco, premio, contato, verificado')
  .eq('verificado', true);
  
  return Response.ok(
    jsonEncode(result),
    headers: {'Content-Type': 'application/json'},
  ); 

}