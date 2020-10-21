FROM base-dockerfile/php-node-docker

COPY www /var/www/app

RUN useradd -u 1001 -G www-data -m dev
RUN chown -R dev:www-data /var/www/app

RUN mkdir -p /var/log/supervisor /var/run/php
WORKDIR /var/www/app

COPY app.conf /etc/apache/site-enabled/app.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl -f http://localhost/ping || exit 1

EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
