FROM php:8.1.2-fpm


# -------------------------------------------------------------
# CONFIG
# -------------------------------------------------------------
# Fichier de version
ADD package.json .
# -------------------------------------------------------------


# -------------------------------------------------------------
# PHP + Composer
# -------------------------------------------------------------
# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip
# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd
# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# Install imagick
RUN apt-get update && apt-get install -y \
    imagemagick libmagickwand-dev --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-enable imagick
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd
RUN pecl install redis
RUN apt-get install -y libzip-dev zip && docker-php-ext-install zip
# Set working directory
WORKDIR /var/www
# -------------------------------------------------------------


# -------------------------------------------------------------
# Nginx
# -------------------------------------------------------------
RUN apt-get update \
    && apt-get install -y nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# && echo "daemon off;" >> /etc/nginx/nginx.conf

# Copy the Nginx config
COPY ./config/nginx/nginx.conf /etc/nginx/conf.d/
# -------------------------------------------------------------


# -------------------------------------------------------------
# Supervisor to start php-fpm and nginx all at once
# -------------------------------------------------------------
RUN apt-get update && apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
COPY ./config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# -------------------------------------------------------------

# Arguments defined in docker-compose.yml
ARG user=defaultuser
ARG uid=1000
# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

#USER $user

# Expose nginx
EXPOSE 8888
CMD ["/usr/bin/supervisord"]

