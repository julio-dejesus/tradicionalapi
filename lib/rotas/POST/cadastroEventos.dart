import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> cadastroEventos(Request request) async {
  final body = await request.readAsString();

  dynamic data;
  try {
    data = jsonDecode(body);
  } catch (e) {
    return Response.badRequest(body: 'JSON inválido.');
  }

  final List<Map<String, dynamic>> eventos = [];

  if (data is Map<String, dynamic>) {
    eventos.add(data);
  } else if (data is List) {
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        eventos.add(item);
      } else {
        return Response.badRequest(body: 'A lista contém um item inválido.');
      }
    }
  } else {
    return Response.badRequest(body: 'Formato JSON inválido. Esperado objeto ou lista de objetos.');
  }

  final List<Map<String, dynamic>> erros = [];
  final List<Map<String, dynamic>> inseridos = [];

  for (final evento in eventos) {
    final organizador = evento['organizador'];
    final dataRealizacao = evento['data_realizacao'];
    final tipoEvento = evento['tipo_evento'];
    final dataInscricao = evento['data_inscricao'];
    final cidade = evento['cidade'];
    final endereco = evento['endereco'];
    final premio = evento['premio'];
    final contato = evento['contato'];

    // Validações
    if (organizador == null ||
        organizador.toString().isEmpty ||
        dataRealizacao == null || 
        dataRealizacao .toString().isEmpty ||
        tipoEvento == null || 
        tipoEvento.toString().isEmpty ||
        cidade == null || 
        cidade.toString().isEmpty ||
        endereco == null ||
        endereco.toString().isEmpty ||
        contato == null || 
        contato.toString().isEmpty) {
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
    }else if (dataInscricao is! String || !dataInscricao.contains('-')) {
      erros.add({
        'evento': evento,
        'erro': 'Campo "data_inscricao" deve estar no formato YYYY-MM-DD.'
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

    if (dataRealizacao is! String || !dataRealizacao.contains('-')) {
      erros.add({
        'evento': evento,
        'erro': 'Campo "data_realizacao" deve estar no formato YYYY-MM-DD.'
      });
      continue;
    }

    try {
      await supabase.from('eventos').insert({
        'organizador': organizador,
        'data_realizacao': dataRealizacao,
        'tipo_evento': tipoEvento,
        'data_inscricao': dataInscricao,
        'cidade': cidade,
        'endereco': endereco,
        'premio': premio,
        'contato': contato,
        'verificado': false,
      });

      inseridos.add({
        'organizador': organizador,
        'data_realizacao': dataRealizacao,
      });
    } catch (e) {
      final errorMsg = e.toString();
      erros.add({
          'evento': evento,
          'erro': 'Erro ao inserir evento: $errorMsg'
        });
    }
  }

  return Response.ok(
    jsonEncode({
      'sucesso': erros.isEmpty,
      'inseridos': inseridos,
      'falhas': erros,
      'summary': {
        'total': eventos.length,
        'inseridos': inseridos.length,
        'falhas': erros.length,
      }
    }),
    headers: {'Content-Type': 'application/json'},
  );
}
