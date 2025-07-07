import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../database.dart';

Future<Response> procuraEventos(Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body);

  // Não irá filtrar por "verificado" pois este tem uma classe específica.
  final camposValidos = ['id', 'organizador', 'dataRealizacao', 'tipoEvento', 'dataInscricao', 'cidade', 'endereco', 'premio', 'contato'];

  List<String> conditions = [];
  List<dynamic> values = [];

  if(data == null || data == ''){
    return Response.badRequest(body: 'A requisição deve conter pelo menos uma especificação');
  }

  for (var campo in camposValidos) {
    if (data.containsKey(campo) && data[campo] != null && data[campo].toString().isNotEmpty) {
      // Campo numérico usa "="
      if (['id', 'dataRealizacao', 'dataInscricao'].contains(campo)) {
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
    SELECT id, organizador, dataRealizacao, tipoEvento, dataInscricao, cidade, endereco, premio, contato, verificado
    FROM Eventos
  ''';

  // Adiciona clausulas, se tiverem sido passadas
  if (conditions.isNotEmpty) {
    query += ' WHERE ' + conditions.join(' AND ');
  }

  final result = db.select(query, values);

  final eventos = result.map((row) => {
    'id': row['id'],
    'organizador': row['organizador'],
    'dataRealizacao': row['dataRealizacao'],
    'tipoEvento': row['tipoEvento'],
    'dataInscricao': row['dataInscricao'],
    'cidade': row['cidade'],
    'endereco': row['endereco'],
    'premio': row['premio'],
    'contato': row['contato'],
    'verificado': row['verificado'],
  }).toList();


  return Response.ok(
    jsonEncode(eventos),
    headers: {'Content-Type': 'application/json'},
  );
}
