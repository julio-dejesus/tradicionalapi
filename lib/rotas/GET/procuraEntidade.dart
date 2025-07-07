import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../database.dart';

Future<Response> procuraEntidade(Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body);

  // Não irá filtrar por "verificado" pois este tem uma classe específica.
  final camposValidos = ['id', 'sigla', 'nome', 'fundado', 'rt', 'cidade', 'endereco'];

  List<String> conditions = [];
  List<dynamic> values = [];

  if(data == null || data == ''){
    return Response.badRequest(body: 'A requisição deve conter pelo menos uma especificação');
  }

  for (var campo in camposValidos) {
    if (data.containsKey(campo) && data[campo] != null && data[campo].toString().isNotEmpty) {
      // Campo numérico usa "="
      if (['id', 'rt', 'fundado'].contains(campo)) {
        conditions.add('$campo = ?');
        values.add(data[campo]);
      } else {
        // Campos varchar usa LIKE
        conditions.add('$campo LIKE ?');
        values.add('%${data[campo]}%');
      }
    }
  }

  // Monta o select
  String query = '''
    SELECT id, sigla, nome, fundado, rt, cidade, endereco, verificado 
    FROM Entidades
  ''';

  // Adiciona clausulas, se tiverem sido passadas
  if (conditions.isNotEmpty) {
    query += ' WHERE ' + conditions.join(' AND ');
  }

  final result = db.select(query, values);

  final entidades = result.map((row) => {
    'id': row['id'],
    'sigla': row['sigla'],
    'nome': row['nome'],
    'fundado': row['fundado'],
    'rt': row['rt'],
    'cidade': row['cidade'],
    'endereco': row['endereco'],
    'verificado': row['verificado'],
  }).toList();

  return Response.ok(
    jsonEncode(entidades),
    headers: {'Content-Type': 'application/json'},
  );
}
