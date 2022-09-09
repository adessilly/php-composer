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

## Local build
docker build -t adessilly/php-composer:latest -t adessilly/php-composer:$npm_package_version .

## Deployment
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v8 -t adessilly/php-composer:latest -t adessilly/php-composer:$npm_package_version . --push