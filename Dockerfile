FROM httpd:latest
ADD --chown=www-data:www-data ./index.html /usr/local/apache2/htdocs/index.html
