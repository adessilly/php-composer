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
      MYSQL_DATABASE: laravelDB
      MYSQL_ROOT_PASSWORD: adminroot
      MYSQL_PASSWORD: user01
      MYSQL_USER: user01
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
  ````
  
Then you can generate whatever composer project like Laravel with :
- `docker-compose up`
- `docker-compose exec app composer create-project laravel/laravel my-proj`







