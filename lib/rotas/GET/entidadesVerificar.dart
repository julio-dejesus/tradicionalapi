import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../database.dart';

Future<Response> entidadesVerificar(Request request) async{

  final result = db.select('SELECT id, sigla, nome, fundado, rt, cidade, endereco, verificado FROM Entidades WHERE verificado = 0');
  final entidades = result.map((row) =>{
    'id': row['id'],
    'sigla': row['sigla'],
    'nome': row['nome'],
    'fundado': row['fundado'],
    'rt': row['rt'],
    'cidade': row['cidade'],
    'endereco': row['endereco'],
    'verificado': row['verificado']
  }).toList();

  return Response.ok(
    jsonEncode(entidades),
    headers: {'Content-Type': 'application/json'},
  );

}