# adessilly/php-composer
PHP + composer

## Example of script (see example folder)

````
version: "3.7"
services:
  app:
    image: adessilly/php-composer:latest
    restart: unless-stopped
    working_dir: /var/www/
    volumes:
      - ./:/var/www

  db:
    image: mysql:5.7
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: '${DB_PASSWORD}'
      MYSQL_DATABASE: '${DB_DATABASE}'
      MYSQL_USER: '${DB_USERNAME}'
      MYSQL_PASSWORD: '${DB_PASSWORD}'
      SERVICE_TAGS: dev
      SERVICE_NAME: mysql
    volumes:
      - ./docker/db:/docker-entrypoint-initdb.d

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    depends_on:
      - db
    links:
      - db
    ports:
      - "8889:80"

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - 8888:80
    volumes:
      - ./:/var/www
      - ./docker/nginx:/etc/nginx/conf.d/

  composer:
    restart: 'no'
    image: composer
    depends_on:
      - db
    command: install --ignore-platform-reqs
    volumes:
      - ./:/app
  ````
  
Then you can generate whatever composer project like Laravel with :
- `docker-compose up`
- `docker-compose exec app composer create-project laravel/laravel my-proj`

## Manifest architecture merge : 
# PUSH FIRST a version for each architecture : -arm and -amd64
docker manifest create adessilly/php-composer:0.1.0 adessilly/php-composer:0.1.0-arm adessilly/php-composer:0.1.0-amd64
docker manifest annotate adessilly/php-composer:0.1.0 adessilly/php-composer:0.1.0-arm --arch arm64
docker manifest push adessilly/php-composer:0.1.0

docker manifest create adessilly/php-composer:latest adessilly/php-composer:0.1.0-arm adessilly/php-composer:0.1.0-amd64
docker manifest annotate adessilly/php-composer:latest adessilly/php-composer:0.1.0-arm --arch arm
docker manifest push adessilly/php-composer:latest
