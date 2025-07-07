import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../database.dart';

Future<Response> eventosVerificar(Request request) async{

  final result = db.select('SELECT id, organizador, dataRealizacao, tipoEvento, dataInscricao, cidade, endereco, premio, contato, verificado FROM Eventos WHERE verificado = 0');
  final entidades = result.map((row) =>{
    'id': row['id'],
    'organizador': row['organizador'],
    'dataRealizacao': row['dataRealizacao'],
    'tipoEvento': row['tipoEvento'],
    'dataInscricao': row['dataInscricao'],
    'cidade': row['cidade'],
    'endereco': row['endereco'],
    'premio': row['premio'],
    'contato': row['contato'],
    'verificado': row['verificado']
  }).toList();

  return Response.ok(
    jsonEncode(entidades),
    headers: {'Content-Type': 'application/json'},
  );

}