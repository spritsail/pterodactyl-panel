ARG ALPINE_VER=3.7

FROM spritsail/alpine:${ALPINE_VER}

ARG ALPINE_VER
ARG PTERODACTYL_PANEL_VER=0.7.7

ENV SUID=www-data SGID=www-data
ENV DATA_DIR=/pterodactyl
ENV PTR_DIR=/var/www

WORKDIR ${PTR_DIR}

# Use php.earth alpine repository for php 7.2 packages
ADD https://repos.php.earth/alpine/phpearth.rsa.pub /etc/apk/keys/phpearth.rsa.pub

RUN apk --no-cache add --repository http://repos.php.earth/alpine/v${ALPINE_VER}/ \
        php7.2-fpm php7.2-gd php7.2-pdo_mysql \
        php7.2-bcmath php7.2-simplexml php7.2-curl php7.2-zip \
        php7.2-pdo php7.2-mbstring php7.2-tokenizer \
        php7.2-openssl php7.2-phar php7.2-json \
        composer \
        git curl \
    \
 && ln -sfv /etc/php/7.2 /etc/php7 \
    \
    # Fetch pterodactyl panel and organise some files/directories
 && curl -fsSL "https://github.com/Pterodactyl/Panel/releases/download/v${PTERODACTYL_PANEL_VER}/panel.tar.gz" \
      | tar xz --strip-components=1 \
 && find \( -name ".gitkeep" -o -name ".githold" -o -name ".gitignore" \) -delete \
 && find storage bootstrap -type d -print0 | xargs -0 -r chmod 755 \
 && find bootstrap/cache -type f -print0 | xargs -0 -r chmod 755 \
    \
    # Install PHP dependencies and libraries
 && composer install --ansi --no-dev --no-scripts --working-dir="${PTR_DIR}" \
    \
    # Add artisan cron schedule to run every minute
 && echo "* * * * * su-exec --env php ${PTR_DIR}/artisan schedule:run >> /dev/null 2>&1" | crontab -u ${SUID} - \
    \
 && chown -R "$SUID:$SGID" ${PTR_DIR} /var/log/php \
# && chmod 755 /usr/local/bin/pterodactyl-start \
 && :

ADD pterodactyl-start /usr/local/bin
ADD php-fpm.conf /etc/php/7.2

VOLUME ${DATA_DIR}

CMD ["/usr/local/bin/pterodactyl-start"]
