# iaw-practica-06

## Arquitectura de una aplicación web LEMP en dos niveles

Para el back-end de esta práctica he usado el mismo que uso en las demás prácticas ya que no requiere ninguna modificación para funcionar correctamente con el servidor Nginx.

Sin embargo para el script del front-end hay que hacer varias modificaciones, tanto en el mismo script como en los archivos de configuración, ya que vamos a sustituir Apache por Nginx:

- Instalamos Nginx por Apache:

    `apt install nginx -y`

- Cambiamos el módulo de php, ya que `apt install php` instala el módulo que funciona con apache:

    `apt install php-fpm`

- Una vez instalado tenemos que modificar el archivo default del directorio /etc/nginx/sites-available/ para que se pueda comunicar con el módulo de php-fpm. La estructura quedaría así:

    ```
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;

        index index.php index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }

        # pass PHP scripts to FastCGI server
        #
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                # With php-fpm (or other unix sockets):
                fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        }

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        location ~ /\.ht {
                deny all;
        }
    }
    ```

- Reiniciamos Nginx y ejecutamos el comando `nginx -t` para comprobar que no hay fallos sintácticos en el archivo. Como prueba adicional se puede crear un archivo .php para accerder por web a él.