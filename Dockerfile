FROM alpine:3.6

MAINTAINER ckappen <christian.kappen@live.de>

ENV COMPOSER_VERSION=1.5.2 \
    COMPOSER_HOME=/composer \
    PATH=$COMPOSER_HOME/vendor/bin:$PATH

COPY install-composer.sh /usr/local/bin/install-composer.sh

RUN apk update --no-cache && \
    apk add bash ca-certificates curl git openssh \
    php7-tokenizer php7-redis php7 php7-common php7-phar php7-curl \
    php7-fpm php7-json php7-zlib php7-xml php7-dom php7-ctype \
    php7-opcache php7-zip php7-iconv php7-pdo php7-pdo_mysql \
    php7-pdo_sqlite php7-pdo_pgsql php7-mbstring php7-session \
    php7-gd php7-mcrypt php7-openssl php7-sockets php7-posix \
    php7-ldap php7-simplexml php7-xmlreader php7-xmlwriter \
    && mkdir -p $COMPOSER_HOME \
    && ( install-composer.sh && rm /usr/local/bin/install-composer.sh ) \
    && export COMPOSER_ALLOW_SUPERUSER=1 \
    && composer global require -a --prefer-dist "hirak/prestissimo:^0.3" \
    && export COMPOSER_ALLOW_SUPERUSER=0 \
    && chmod -R 0777 $COMPOSER_HOME/cache \
    && rm -Rf /var/cache/apk/* \
    && rm -Rf $COMPOSER_HOME/cache/*

VOLUME ["/project", "$COMPOSER_HOME/cache"]
WORKDIR /project

ENTRYPOINT ["composer"]
CMD ["--version"]