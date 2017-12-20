FROM php:7.1-fpm-alpine

MAINTAINER lkochniss <lukas.kochniss+docker@gmail.com>

ENV COMPOSER_VERSION=1.5.2 \
    COMPOSER_HOME=/composer \
    PATH=$COMPOSER_HOME/vendor/bin:$PATH \
    XDEBUG_VERSION=2.5.5\
    XDEBUG_PORT=9000

COPY install-composer.sh /usr/local/bin/install-composer.sh

RUN docker-php-source extract \
    && apk add --update --virtual .build-deps autoconf g++ make pcre-dev icu-dev openssl-dev git openssh \
    && cd /usr/local/etc/php/ \
    && curl -LO http://xdebug.org/files/xdebug-$XDEBUG_VERSION.tgz \
    && tar -zxvf xdebug-$XDEBUG_VERSION.tgz \
    && cd xdebug-$XDEBUG_VERSION && phpize \
    && ./configure --enable-xdebug && make && make install \
    && echo "zend_extension=xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_port=${XDEBUG_PORT}" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && mkdir -p $COMPOSER_HOME \
    && ( install-composer.sh && rm /usr/local/bin/install-composer.sh ) \
    && export COMPOSER_ALLOW_SUPERUSER=1 \
    && composer global require -a --prefer-dist "hirak/prestissimo:^0.3" \
    && export COMPOSER_ALLOW_SUPERUSER=0 \
    && chmod -R 0777 $COMPOSER_HOME/cache \
    && rm -Rf /var/cache/apk/* \
    && rm -Rf $COMPOSER_HOME/cache/* \
    && docker-php-source delete \
    && apk del --purge .build-deps \
    && rm -rf /tmp/pear \
    && rm -rf /var/cache/apk/*

VOLUME ["/project", "$COMPOSER_HOME/cache"]
WORKDIR /project

ENTRYPOINT ["composer"]
CMD ["--version"]
