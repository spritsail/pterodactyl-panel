FROM spritsail/alpine:3.7

WORKDIR /var/www

ARG PTERODACTYL_PANEL_VER=0.7.7
ARG COMPOSER_VER=1.6.5

ADD pterodactyl-start /usr/local/bin

RUN apk --no-cache add \
        php7-fpm php7-gd php7-pdo_mysql \
        php7-bcmath php7-simplexml php7-curl php7-zip \
        php7-pdo php7-mbstring php7-tokenizer \
        php7-openssl php7-phar php7-json \
        git curl \
\
 # This is a temporary hack. composer should be installed from the repos in alpine:3.8
 && curl -fsSL -o /usr/bin/composer "https://getcomposer.org/download/${COMPOSER_VER}/composer.phar" \
 && chmod 755 /usr/bin/composer \
 && curl -fsSL "https://github.com/Pterodactyl/Panel/releases/download/v${PTERODACTYL_PANEL_VER}/panel.tar.gz" \
      | tar xz --strip-components=1 -C /var/www \
 && chmod -R 755 /var/www/storage/* /var/www/bootstrap/cache \
 && composer install --ansi --no-dev --no-scripts --working-dir=/var/www/ \
 # Do we actually need these?
 #&& mkdir -p /var/www/storage/app/public \
 #&& mkdir -p /var/www/storage/framework/cache \
 #&& mkdir -p /var/www/storage/framework/sessions \
 #&& mkdir -p /var/www/storage/framework/views \
 #&& mkdir -p /var/www/storage/logs \
 #&& mkdir -p /var/www/bootstrap/cache \
 && chown -R www-data:www-data /var/www \
 && chmod 755 /usr/local/bin/pterodactyl-start

RUN ["/usr/local/bin/pterodactyl-start"]
