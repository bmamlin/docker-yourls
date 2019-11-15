FROM ubuntu:18.04

ENV APP_ROOT /yourls
ENV DEBIAN_FRONTEND noninteractive

RUN mkdir -p ${APP_ROOT} \
  && apt-get update \
  && apt-get install -y curl apache2 supervisor php php-mysql php-curl \
  && unset DEBIAN_FRONTEND \
  && rm -rf /var/lib/apt/lists/* \
  && curl -L https://github.com/YOURLS/YOURLS/archive/1.7.4.tar.gz | tar -zx -C ${APP_ROOT} --strip-components=1 \
  # undo https://github.com/YOURLS/YOURLS/commit/d97af0f1dc3ae5886db8a7561c1845432d001926
  # that clears active plugins whenever web container restarts
  && sed -i 's/^\(.*yourls_update_option.*active_plugins.*\)$/\/\/\1/' ${APP_ROOT}/includes/functions-install.php \
  && phpenmod mysql \
  && echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf \
  && a2enconf fqdn \
  && a2enmod php7.2 rewrite

COPY docker/start-yourls.sh /usr/bin/start-yourls.sh
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/vhost.conf /etc/apache2/sites-enabled/000-default.conf
COPY docker/config.php ${APP_ROOT}/user/config.php
COPY docker/migrate.php ${APP_ROOT}/migrate.php
COPY docker/.htaccess ${APP_ROOT}/.htaccess
COPY docker/index.php ${APP_ROOT}/index.php
COPY plugins ${APP_ROOT}/user/plugins

WORKDIR ${APP_ROOT}

RUN chown -R www-data:www-data ${APP_ROOT}

EXPOSE 80
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
