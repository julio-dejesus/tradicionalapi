# 1️⃣ Usa a imagem oficial do Dart como base
FROM dart:stable

# 2️⃣ Define o diretório de trabalho dentro do container
WORKDIR /app

# 🔧 Instala o SQLite nativo
RUN apt-get update && apt-get install -y libsqlite3-dev

# 3️⃣ Copia arquivos de dependência para instalar pacotes
COPY pubspec.* ./

# 4️⃣ Roda "dart pub get" para instalar dependências
RUN dart pub get

# 5️⃣ Copia o restante do projeto (código fonte)
COPY . .

# 6️⃣ Define uma variável de ambiente chamada PORT (necessária para o Render)
ENV PORT=8080

# 7️⃣ Expõe essa porta no container
EXPOSE 8080

# 8️⃣ Comando que roda sua aplicação Dart
CMD ["dart", "bin/main.dart"]
