import 'dart:convert';
import 'dart:io';
import 'package:shelf_router/shelf_router.dart';
import 'package:tradicional/rotas/GET/entidadesVerificar.dart';
import 'package:tradicional/rotas/GET/eventosVerificar.dart';
import 'package:tradicional/rotas/GET/listarEventos.dart';
import 'package:tradicional/rotas/GET/listarUsuarios.dart';
import 'package:tradicional/rotas/GET/procuraEntidade.dart';
import 'package:tradicional/rotas/GET/procuraEventos.dart';
import 'package:tradicional/rotas/POST/cadastroEntidades.dart';
import 'package:tradicional/rotas/GET/listarEntidades.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:tradicional/database.dart';
import 'package:tradicional/rotas/POST/cadastroEventos.dart';
import 'package:tradicional/rotas/POST/cadastroUsuarios.dart';
import 'package:tradicional/rotas/POST/logar.dart';
import 'package:tradicional/rotas/DELETE/deletarEntidade.dart';
import 'package:tradicional/rotas/DELETE/deletarEvento.dart';
import 'package:tradicional/rotas/DELETE/deletarUsuario.dart';
import 'package:tradicional/rotas/PUT/verificarEntidade.dart';
import 'package:tradicional/rotas/PUT/verificarEvento.dart';
import 'package:tradicional/verificarJWT.dart';

void main() async {
  iniciaBanco();//inicia o sqlite

  final publicRouter = Router()
    ..get('/', (Request request) {
      return Response.ok(jsonEncode({'status': 'ok'}), headers: {
        'Content-Type': 'application/json'
      });
    })
    ..post('/logar', logar)
    ..post('/cadastroEventos', cadastroEventos)
    ..post('/cadastroEntidades', cadastroEntidades)
    ..get('/entidadesVerificar', entidadesVerificar)
    ..get('/eventosVerificar', eventosVerificar)
    ..get('/listarEntidades', listarEntidades)
    ..get('/listarEventos', listarEventos)
    ..get('/procuraEntidades', procuraEntidade)
    ..get('/procuraEventos', procuraEventos);
  ;

  final protectedRouter = Router()
    ..post('/cadastroUsuarios', cadastroUsuarios)
    ..get('/listarUsuarios', listarUsuarios)
    ..delete('/deletarEntidade/<id>', deletarEntidade)
    ..delete('/deletarEvento/<id>', deletarEvento)
    ..delete('/deletarUsuario/<id>', deletarUsuario)
    ..put('/verificarEntidade/<id>', verificarEntidade)
    ..put('/verificarEvento/<id>', verificarEvento);

  final publicHandler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(publicRouter);

  final protectedHandler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(verificarJWTMiddleware())
      .addHandler(protectedRouter);

  final handler = Cascade()
      .add(protectedHandler)
      .add(publicHandler)
      .handler;

  final server = await io.serve(handler, InternetAddress.anyIPv4, // Inicia o servidor na porta 8080
  //final server = await io.serve(
      //handler,
      //InternetAddress.anyIPv4,
      int.parse(Platform.environment['PORT'] ?? '8080'));//altera para que o endpoint possa definir a porta
      //8080);

  print('Servidor rodando: http://${server.address.address}:${server.port}');
}
