import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../supabase_client.dart';

Future<Response> cadastroEntidades(Request request) async {
  final body = await request.readAsString();

  dynamic data;
  try {
    data = jsonDecode(body);
  } catch (e) {
    return Response.badRequest(body: 'JSON inválido.');
  }

  final List<Map<String, dynamic>> entidades = [];

  if (data is Map<String, dynamic>) {
    entidades.add(data);
  } else if (data is List) {
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        entidades.add(item);
      } else {
        return Response.badRequest(body: 'A lista contém um item inválido.');
      }
    }
  } else {
    return Response.badRequest(body: 'Formato JSON inválido. Esperado objeto ou lista.');
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
    if (sigla == null || 
        sigla.toString().isEmpty ||
        nome == null || 
        nome.toString().isEmpty ||
        fundado == null || 
        rt == null || 
        cidade == null || 
        cidade.toString().isEmpty) {
      erros.add({
        'entidade': entidade,
        'erro': 'Campos obrigatórios ausentes.'
      });
      continue;
    }
    
    if (fundado is! String || !fundado.contains('-')) {
      erros.add({
        'entidade': entidade,
        'erro': 'Campo "fundado" deve estar no formato YYYY-MM-DD.'
      });
      continue;
    }

    try {
      await supabase.from('entidades').insert({
        'sigla': sigla,
        'nome': nome,
        'fundado': fundado,
        'rt': rt,
        'cidade': cidade,
        'endereco': endereco,
        'verificado': false
      });

      inseridas.add({
        'sigla': sigla,
         'nome': nome,
          'rt': rt
      });
    } catch (e) {
      final errorMsg = e.toString();

      if (errorMsg.contains('23505')) {
        erros.add({
          'entidade': entidade,
          'erro': 'Já existe uma entidade com essa sigla, nome e RT.'
        });
      } else {
        erros.add({
          'entidade': entidade,
          'erro': 'Erro ao inserir entidade: $errorMsg'
        });
      }
    }
  }

  return Response.ok(
    jsonEncode({
      'sucesso': erros.isEmpty,
      'inseridas': inseridas,
      'falhas': erros,
      'summary': {
        'total': entidades.length,
        'inseridas': inseridas.length,
        'falhas': erros.length,
      }
    }),
    headers: {'Content-Type': 'application/json'},
  );
}