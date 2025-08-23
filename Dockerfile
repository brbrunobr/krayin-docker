# Use a imagem base do PHP com Apache
FROM php:8.1-apache

# Argumentos para o build
ARG uid
ARG user
ARG container_project_path=/var/www/html

# Instalar dependências do sistema necessárias para o Krayin e Composer
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    calendar \
    && docker-php-ext-install pdo_mysql zip gd mbstring exif pcntl bcmath opcache

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
RUN git clone https://github.com/krayin/crm.git .

# Instalar dependências do Composer
# A flag --no-dev é boa prática para produção
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Copiar o arquivo .env de exemplo
RUN cp .env.example .env

# Definir permissões corretas para o Apache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# --- FIM DAS MODIFICAÇÕES IMPORTANTES ---

# Expor a porta interna (o Coolify vai mapear isso )
EXPOSE 80

# O comando de inicialização já é gerenciado pela imagem base do Apache
