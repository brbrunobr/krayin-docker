#!/bin/bash

# Por segurança, espera um segundo para garantir que todos os serviços estejam prontos.
sleep 1

# Muda para o diretório da aplicação
cd /var/www/html

echo "--- Executando script de inicialização automático ---"

# 1. Garante que as permissões de escrita estejam corretas.
echo "Ajustando permissões..."
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# 2. Limpa caches para garantir que as configurações mais recentes sejam usadas.
echo "Limpando caches..."
php artisan optimize:clear

# 3. Executa as migrações do banco de dados.
# Se as tabelas já existirem, não fará nada. É seguro executar sempre.
echo "Verificando migrações do banco de dados..."
php artisan migrate --force

# 4. Garante que o elo simbólico para os arquivos de upload exista.
echo "Criando o elo simbólico do storage..."
php artisan storage:link

# 5. Garante que o arquivo 'installed' exista para evitar o redirecionamento.
echo "Criando o arquivo 'installed'..."
touch storage/installed

echo "--- Script de inicialização concluído. Iniciando o Apache. ---"

# 6. Executa o comando padrão do contêiner para iniciar o servidor web.
# Esta linha é MUITO importante e deve ser a última.
exec apache2-foreground
