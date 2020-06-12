#!/bin/bash
cd /var/www/html
composer install

php artisan config:clear
php artisan key:generate
php artisan config:cache
php artisan cache:clear

sleep 30
php artisan migrate:refresh --seed
setfacl -dR -m u:www-data:rwX /var/www/html
setfacl -R -m u:www-data:rwX tmp

