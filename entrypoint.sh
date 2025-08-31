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

# 4. O COMANDO ESSENCIAL: Popula o banco com os dados iniciais (funções, etc.)
# DEPOIS (solução):
echo "Verificando se o banco precisa ser populado..."
LEAD_COUNT=$(php artisan tinker --execute="echo \Webkul\Lead\Models\Lead::count();")
PIPELINE_COUNT=$(php artisan tinker --execute="echo \Webkul\Lead\Models\Pipeline::count();")

if [ "$LEAD_COUNT" -eq "0" ] && [ "$PIPELINE_COUNT" -eq "0" ]; then
    echo "Banco vazio detectado. Populando com dados iniciais..."
    php artisan db:seed --force
    echo "Banco de dados populado com os dados iniciais!"
else
    echo "Dados existentes detectados. Pulando seeders para preservar dados personalizados."
    echo "Leads encontrados: $LEAD_COUNT"
    echo "Pipelines encontrados: $PIPELINE_COUNT"
fi

# 5. Garante que o elo simbólico para os arquivos de upload exista.
echo "Criando o elo simbólico do storage..."
php artisan storage:link

# 6. Garante que o arquivo 'installed' exista para evitar o redirecionamento.
echo "Criando o arquivo 'installed'..."
touch storage/installed

# 6.1. Gera a APP_KEY se ainda não existir
if ! grep -q "^APP_KEY=" .env || grep -q "^APP_KEY=$" .env; then
    echo "Gerando APP_KEY..."
    php artisan key:generate --force
    echo "APP_KEY gerada com sucesso = $(grep ^APP_KEY= .env | cut -d= -f2)"
fi

echo "--- Script de inicialização concluído. Iniciando o Apache. ---"

# 7. Executa o comando padrão do contêiner para iniciar o servidor web.
# Esta linha é MUITO importante e deve ser a última.
exec apache2-foreground
