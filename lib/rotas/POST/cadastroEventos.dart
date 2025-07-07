import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/common.dart';
import '../../database.dart';

Future<Response> cadastroEventos(Request request) async {
  final body = await request.readAsString();

  dynamic data;
  try {
    data = jsonDecode(body);
  } catch (e) {
    return Response.badRequest(body: 'JSON inválido.');
  }

  List<Map<String, dynamic>> eventos = [];

  if (data is Map<String, dynamic>) {
    eventos.add(data);
  } else if (data is List) {
    for (var item in data) {
      if (item is Map<String, dynamic>) {
        eventos.add(item);
      } else {
        return Response.badRequest(body: 'A lista contém um item inválido.');
      }
    }
  } else {
    return Response.badRequest(body: 'Formato JSON inválido. Esperado objeto ou lista de objetos.');
  }

  final erros = [];
  final inseridos = [];

  for (final evento in eventos) {
    final organizador = evento['organizador'];
    final dataRealizacao = evento['dataRealizacao'];
    final tipoEvento = evento['tipoEvento'];
    final dataInscricao = evento['dataInscricao'];
    final cidade = evento['cidade'];
    final endereco = evento['endereco'];
    final premio = evento['premio'];
    final contato = evento['contato'];

    // Validações
    if (organizador == null || organizador == '' ||
        dataRealizacao == null || dataRealizacao == '' ||
        tipoEvento == null || tipoEvento == '' ||
        cidade == null || cidade == '' ||
        endereco == null || endereco == '' ||
        contato == null || contato == '') {
      erros.add({
        'evento': evento,
        'erro': 'Campos obrigatórios ausentes.'
      });
      continue;
    }

    if (dataInscricao == '') {
      erros.add({
        'evento': evento,
        'erro': 'Preencha a data limite de inscrição ou use null.'
      });
      continue;
    }

    if (premio == '') {
      erros.add({
        'evento': evento,
        'erro': 'Se não houver prêmio, passe null.'
      });
      continue;
    }

    try {
      final stmt = db.prepare('''
        INSERT INTO Eventos (
          organizador, dataRealizacao, tipoEvento, dataInscricao,
          cidade, endereco, premio, contato
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''');

      stmt.execute([
        organizador,
        dataRealizacao,
        tipoEvento,
        dataInscricao,
        cidade,
        endereco,
        premio,
        contato
      ]);
      stmt.dispose();

      inseridos.add({
        'organizador': organizador,
        'dataRealizacao': dataRealizacao,
        'tipoEvento': tipoEvento
      });
    } on SqliteException catch (e) {
      if (e.message.contains('UNIQUE')) {
        erros.add({
          'evento': evento,
          'erro': 'Já existe um evento com esse tipo, data, organizador e endereço.'
        });
      } else {
        erros.add({
          'evento': evento,
          'erro': 'Erro no banco de dados: ${e.message}'
        });
      }
    } catch (e) {
      erros.add({
        'evento': evento,
        'erro': 'Erro inesperado: ${e.toString()}'
      });
    }
  }

  return Response.ok(
    jsonEncode({
      'sucesso': inseridos,
      'falhas': erros
    }),
    headers: {'Content-Type': 'application/json'},
  );
}
