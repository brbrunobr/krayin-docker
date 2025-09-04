# Use a imagem base do PHP com Apache
# FROM php:8.1-apache
FROM php:8.2-apache

# Argumentos para o build
ARG uid
ARG user
ARG container_project_path=/var/www/html

# Configurar APT para melhor resiliência
RUN echo 'Acquire::http::Timeout "300";' > /etc/apt/apt.conf.d/99timeout && \
    echo 'Acquire::https::Timeout "300";' >> /etc/apt/apt.conf.d/99timeout && \
    echo 'Acquire::ftp::Timeout "300";' >> /etc/apt/apt.conf.d/99timeout && \
    echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/99retries

# Atualizar lista de pacotes com retry
RUN apt-get update || (sleep 5 && apt-get update) || (sleep 10 && apt-get update)

# Instalar dependências do sistema necessárias para o Krayin e Composer
RUN apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libc-client-dev \
    libkrb5-dev \
    && rm -rf /var/lib/apt/lists/*

# Configurar e instalar extensão IMAP separadamente
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

# Instalar outras extensões PHP
RUN docker-php-ext-install pdo_mysql zip gd mbstring exif pcntl bcmath opcache intl calendar

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar o Apache para apontar para a pasta public do Laravel
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite

# Mudar para o diretório de trabalho
WORKDIR /var/www/html

# --- INÍCIO DAS MODIFICAÇÕES IMPORTANTES ---

# Clonar o repositório do Krayin CRM
# RUN git clone https://github.com/krayin/crm.git .
# RUN git -c http.sslVerify=false clone --depth 1 https://github.com/krayin/crm.git .
# RUN GIT_TERMINAL_PROMPT=0 git clone --depth 1 https://github.com/krayin/crm.git .

RUN git clone https://github.com/brbrunobr/laravel-crm.git .

# --- INÍCIO DA CORREÇÃO DE PROXY ---
# Força o Laravel a confiar nos cabeçalhos do proxy reverso do Coolify (resolve problemas de HTTPS/Mixed Content)
RUN sed -i "s/protected \$proxies;/protected \$proxies = '*';/" app/Http/Middleware/TrustProxies.php
# --- FIM DA CORREÇÃO DE PROXY ---

# --- PERSONALIZADO - BRUNO ---

# Instalar dependências do Composer
# A flag --no-dev é boa prática para produção
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Copiar o arquivo .env de exemplo
RUN cp .env.example .env

# Definir permissões corretas para o Apache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# --- FIM DAS MODIFICAÇÕES IMPORTANTES ---

# Copia o nosso novo script de inicialização para dentro do contêiner
COPY entrypoint.sh /usr/local/bin/

# Torna o script executável
RUN chmod +x /usr/local/bin/entrypoint.sh

# Define o nosso script como o ponto de entrada do contêiner
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Expor a porta interna (o Coolify vai mapear isso )
EXPOSE 80

# O comando de inicialização já é gerenciado pela imagem base do Apache
