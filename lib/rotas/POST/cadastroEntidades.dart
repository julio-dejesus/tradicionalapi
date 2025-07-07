import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/common.dart';
import '../../database.dart';

Future<Response> cadastroEntidades(Request request) async {
  final body = await request.readAsString();

  dynamic data;
  try {
    data = jsonDecode(body);
  } catch (e) {
    return Response.badRequest(body: 'JSON inválido.');
  }

  List<Map<String, dynamic>> entidades = [];

  if (data is Map<String, dynamic>) {
    entidades.add(data);
  } else if (data is List) {
    for (var item in data) {
      if (item is Map<String, dynamic>) {
        entidades.add(item);
      } else {
        return Response.badRequest(body: 'A lista contém um item inválido.');
      }
    }
  } else {
    return Response.badRequest(body: 'Formato JSON inválido. Esperado objeto ou lista de objetos.');
  }

  final erros = [];
  final inseridas = [];

  for (final entidade in entidades) {
    final sigla = entidade['sigla'];
    final nome = entidade['nome'];
    final fundado = entidade['fundado'];
    final rt = entidade['rt'];
    final cidade = entidade['cidade'];
    final endereco = entidade['endereco'];

    // Validação de campos obrigatórios
    if (sigla == null || sigla == '' ||
        nome == null || nome == '' ||
        fundado == null || fundado == '' ||
        rt == null || rt.toString().isEmpty ||
        cidade == null || cidade == '') {
      erros.add({
        'entidade': entidade,
        'erro': 'Campos obrigatórios ausentes.'
      });
      continue;
    }

    try {
      final stmt = db.prepare(
          'INSERT INTO Entidades (sigla, nome, fundado, rt, cidade, endereco) VALUES (?, ?, ?, ?, ?, ?);'
      );
      stmt.execute([sigla, nome, fundado, rt, cidade, endereco]);
      stmt.dispose();
      inseridas.add({'sigla': sigla, 'nome': nome, 'rt': rt});
    } on SqliteException catch (e) {
      if (e.message.contains('UNIQUE')) {
        erros.add({
          'entidade': entidade,
          'erro': 'Já existe uma entidade com essa sigla, nome e RT.'
        });
      } else {
        erros.add({
          'entidade': entidade,
          'erro': 'Erro no banco de dados: ${e.message}'
        });
      }
    } catch (e) {
      erros.add({
        'entidade': entidade,
        'erro': 'Erro inesperado: ${e.toString()}'
      });
    }
  }

  return Response.ok(
    jsonEncode({
      'sucesso': inseridas,
      'falhas': erros
    }),
    headers: {'Content-Type': 'application/json'},
  );
}