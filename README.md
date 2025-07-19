# API Tradicional

Uma API desenvolvida em Dart para buscar e gerenciar informações relacionadas à cultura gaúcha.
Essa API fornece acesso a dados sobre entidades culturais e eventos, com funcionalidades de autenticação via JWT para operações restritas.

## 🚀 Como executar o projeto

Para usar esta API você precisa utilizar um cliente HTTP como:
[Postman](https://www.postman.com/),
[Insomnia](https://insomnia.rest/) ou até mesmo `curl` no terminal.

A API está hospedada em:  
👉 [https://api-tradicional.onrender.com](https://tradicionalapi.onrender.com/)

Basta enviar as requisições para esse endereço conforme os endpoints descritos abaixo.

# 📌 Endpoints Disponíveis

## 🔍 Públicos

    GET /listarEntidades
    Lista todas as entidades já verificadas.

    GET /listarEventos
    Lista todos os eventos já verificados.

    GET /entidadesVerificar
    Lista as entidades ainda não verificadas.

    GET /eventosVerificar
    Lista os eventos ainda não verificados.

    GET /procuraEntidade
    Busca por entidades a partir de um ou mais filtros no corpo JSON:
    id, sigla, nome, fundado, rt, cidade, endereco

    GET /procuraEventos
    Busca por eventos a partir de um ou mais filtros no corpo JSON:
    id, organizador, dataRealizacao, tipoEvento, dataInscricao, cidade, endereco, premio, contato

    POST /logar
    Gera um token JWT.
    Exemplo de corpo:
    {
        "login": "usuario",
        "senha": "senha123"
    }

    POST /cadastroEntidade
    Cadastra uma nova entidade (não verificada).
    Campos: sigla, nome, fundado, rt, cidade, endereco (opcional)

    POST /cadastroEvento
    Cadastra um novo evento (não verificado).
    Campos: organizador, dataRealizacao, tipoEvento, dataInscricao (opcional), cidade, endereco, premio (opcional), contato (opcional)

## 🔒 Requerem autenticação (JWT)

    GET /listarUsuarios
    Lista todos os usuários cadastrados.

    DELETE /deletarEntidade/{id}
    Deleta uma entidade pelo ID.

    DELETE /deletarEvento/{id}
    Deleta um evento pelo ID.

    DELETE /deletarUsuario/{id}
    Deleta um usuário pelo ID.

    PUT /verificarEntidade
    Marca uma entidade como verificada.
    PUT /verificarEvento
    Marca um evento como verificado.
    Corpo esperado:

    {
        "verificado": "ok"
    }

    POST /cadastroUsuarios
    Cadastra um novo usuário.
    Campos : nome, login, email (opcional), senha

# 🔐 Autenticação
A autenticação é feita via token JWT. Após o login, inclua o token no cabeçalho das requisições protegidas:

Authorization: Bearer <seu_token_aqui>
