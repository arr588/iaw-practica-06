#!/bin/bash

#-------------------------------------------------------------------------------
# Configuramos las variables
#-------------------------------------------------------------------------------

# Definimos la contraseña de root de MySQL Server
DB_ROOT_PASSWD=root

# Variable base de datos
DIR_GIT=/home/ubuntu/pag_web

# ------------------------------------------------------------------------------
# Instalación de la pila LAMP
# ------------------------------------------------------------------------------

# Habilitamos el modo de shell para mostrar los comandos que se ejecutan
set -x

# Actualizamos la lista de paquetes
apt update -y

# Instalamos el sistema gestor de base de datos
apt install mysql-server -y

# Actualizamos la contraseña de root de MySQL
mysql -u root <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$DB_ROOT_PASSWD';"
mysql -u root <<< "FLUSH PRIVILEGES;"

# Cambiamos la IP del archivo de configuración de MySQL
sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Reiniciamos el servicio
sudo systemctl restart mysql

# ------------------------------------------------------------------------------
# Instalamos la base de datos
# ------------------------------------------------------------------------------

# Descargamos los archivos desde GitHub
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git $DIR_GIT

# Borramos lo que no necesitemos del repositorio
rm -rfv $DIR_GIT/src

# Insertamos la base de datos en MySQL
mysql --user=root --password=$DB_ROOT_PASSWD < $DIR_GIT/db/database.sql