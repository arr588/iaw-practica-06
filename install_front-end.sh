#!/bin/bash

#-------------------------------------------------------------------------------
# Configuramos las variables
#-------------------------------------------------------------------------------

# Variables GoAcces
HTTPASSWD_USER=usuario
HTTPASSWD_PASSWD=usuario
HTTPASSWD_DIR=/home/ubuntu

# Variables página web
DIR_GIT=/home/ubuntu/pag_web

# IP back-end
IP=172.31.41.218

# ------------------------------------------------------------------------------
# Instalación de la máquina LAMP front-end
# ------------------------------------------------------------------------------

# Habilitamos el modo de shell para mostrar los comandos que se ejecutan
set -x

# Actualizamos la lista de paquetes
apt update -y

# Instalamos el servidor web Nginx
apt install nginx -y

# Instalamos los módulos necesarios de PHP
apt install php-fpm php-mysql -y

# Instalamos los módulos de phpMyAdmin excepto el principal
apt install php-mbstring php-zip php-gd php-json php-curl -y

# Descargamos Adminer
mkdir /var/www/html/adminer
cd /var/www/html/adminer
wget https://github.com/vrana/adminer/releases/download/v4.7.7/adminer-4.7.7-mysql.php
mv adminer-4.7.7-mysql.php index.php

# Instalación de GoAccess
echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -
apt-get update -y
apt-get install goaccess -y

# Creacion de un directorio para consultar las estadísticas
mkdir -p /var/www/html/stats

# Lanzamos el proceso
nohup goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html &
htpasswd -bc $HTTPASSWD_DIR/.htpasswd $HTTPASSWD_USER $HTTPASSWD_PASSWD

# Configuramos php-fmp para que se comunique a través de un puerto
#cp /home/ubuntu/www.conf /etc/php/7.4/fpm/pool.d

# Reiniciamos php-fmp
#systemctl restart php7.4-fpm

# Copiamos el archivo de configuración de Nginx
cp /home/ubuntu/default /etc/nginx/sites-available/

# Reiniciamos Nginx
systemctl restart nginx

# Comprobamos que no hay ningun fallo en el archivo
nginx -t

# Instalamos Unzip
apt install unzip -y

# Instalamos phpMyAdmin
cd /home/ubuntu
rm -rf phpMyAdmin-5.0.4-all-lenguages.zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.zip
unzip phpMyAdmin-5.0.4-all-languages.zip
rm -rf phpMyAdmin-5.0.4-all-languages.zip
rm -rf /var/www/html/phpmyadmin
mv phpMyAdmin-5.0.4-all-languages /var/www/html/phpmyadmin
cp config.inc.php /var/www/html/phpmyadmin/

# Cambiamos los permisos de la carpeta html
cd /var/www/html
chown www-data:www-data * -R

# ------------------------------------------------------------------------------
# Instalación de la aplicación web propuesta
# ------------------------------------------------------------------------------

# Descargamos los archivos desde GitHub
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git $DIR_GIT

# Borramos el index.html
rm /var/www/html/index.html

# Borramos la base de datos del repositorio
rm -rfv $DIR_GIT/db

# Movemos los archivos de src a la carpeta html
mv $DIR_GIT/src/* /var/www/html

# Cambiamos la IP de la base de datos a la del backend
sed -i "s/localhost/$IP/" /var/www/html/config.php

# Reiniciamos nginx
systemctl restart nginx