FROM deb-base:latest

LABEL org.opencontainers.image.authors="erwin@emichiels.nl"

ARG DEBIAN_FRONTEND="noninteractive"

ENV TZ=Europe/Amsterdam
ENV PHP=8.4
#ENV oldPHP=8.3

RUN apt update && \
  apt install -y procps --option=Dpkg::Options::=--force-confdef && \
  apt install apache2 libjs-jquery modsecurity-crs mariadb-client sharutils imagemagick rsync git unzip socat bluetooth libbluetooth3 libbluetooth-dev libboost-date-time-dev libboost-system-dev libboost-filesystem-dev libboost-regex-dev libpcre2-8-0 tzdata -y && \
  apt install libphp${PHP}-embed php${PHP} php${PHP}-fpm php${PHP}-curl php${PHP}-gd php${PHP}-intl php${PHP}-mysql php${PHP}-xml php${PHP}-zip php${PHP}-mbstring php${PHP}-cgi php${PHP}-bcmath php${PHP}-gmp php${PHP}-imagick php${PHP}-ldap php-pear php${PHP}-redis php${PHP}-bz2 -y && \
  if [ $oldPHP ]; then apt install libphp${oldPHP}-embed php${oldPHP} php${oldPHP}-fpm php${oldPHP}-curl php${oldPHP}-gd php${oldPHP}-intl php${oldPHP}-mysql php${oldPHP}-xml php${oldPHP}-zip php${oldPHP}-mbstring php${oldPHP}-cgi php${oldPHP}-bcmath php${oldPHP}-gmp php${oldPHP}-imagick php${oldPHP}-ldap php-pear php${oldPHP}-redis php${oldPHP}-bz2 -y; fi

# Set default PHP version defaults
RUN sed -i "s/^.*memory_limit =.*/memory_limit = 1024M/" /etc/php/${PHP}/fpm/php.ini && \
    sed -i "s/.*post_max_size =.*/post_max_size = 10M/" /etc/php/${PHP}/fpm/php.ini && \
    sed -i "s/.*upload_max_filesize =.*/upload_max_filesize = 10M/" /etc/php/${PHP}/fpm/php.ini && \
    sed -i "s?.*date\.timezone =.*?date.timezone = Europe/Amsterdam?" /etc/php/${PHP}/fpm/php.ini && \
    sed -i "s/.*opcache.enable=.*/opcache.enable = 1/" /etc/php/${PHP}/fpm/php.ini && \
    sed -i "s/.*opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer = 20/" /etc/php/${PHP}/fpm/php.ini

# Install old PHP version
RUN if [ $oldPHP ]; then sed -i "s/^.*memory_limit =.*/memory_limit = 1024M/" /etc/php/${oldPHP}/fpm/php.ini && \
    sed -i "s/.*post_max_size =.*/post_max_size = 10M/" /etc/php/${oldPHP}/fpm/php.ini && \
    sed -i "s/.*upload_max_filesize =.*/upload_max_filesize = 10M/" /etc/php/${oldPHP}/fpm/php.ini && \
    sed -i "s?.*date\.timezone =.*?date.timezone = Europe/Amsterdam?" /etc/php/${oldPHP}/fpm/php.ini && \
    sed -i "s/.*opcache.enable=.*/opcache.enable = 1/" /etc/php/${oldPHP}/fpm/php.ini && \
    sed -i "s/.*opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer = 20/" /etc/php/${oldPHP}/fpm/php.ini; fi

# Install python
RUN apt install libawl-php python3-oauthlib python3-requests-oauthlib python3-oauthlib python3-configargparse python3-pip python3-metaconfig redis-server -y && \
  rm /usr/lib/python3.11/EXTERNALLY-MANAGED && \
  pip install mysql-connector-python pytz && \
  rm -rf /var/lib/apt/lists/*

# Delete php cron
RUN rm -f /etc/cron.d/php && \
    rm -f /etc/cron.daily/apt-compat

# Copy files to root
COPY rootfs /

# Configure apache
RUN a2dismod mpm_worker mpm_prefork && \
  a2enmod http2 mpm_event ssl remoteip rewrite headers proxy_fcgi proxy_http && \
  sed -i "/Listen 80/a Listen 83" /etc/apache2/ports.conf && \
  sed -i "/<\/FilesMatch>/s/.*/&\n\n<FilesMatch \.php$>\n    SetHandler \"proxy:unix:\/run\/php\/php${PHP}-fpm.sock|fcgi:\/\/localhost\/\"\n<\/FilesMatch>/" /etc/apache2/apache2.conf

# Update supervisor config
RUN PHPshort=`echo ${PHP} | sed -e 's/\.//'` && \
  sed -i /etc/supervisor/conf.d/supervisor.conf -e "s/{PHP}/${PHP}/" -e "s/{PHPshort}/${PHPshort}/" && \
  if [ $oldPHP ]; then oldPHPshort=`echo ${oldPHP} | sed -e 's/\.//'` && \
    printf "\n\
[program:php${oldPHP}-fpm]\n\
command=/usr/sbin/php-fpm${oldPHP} -F\n\
autostart=true\n\
autorestart=unexpected\n\
stdout_logfile=/var/log/qnap/phpfpm-stdout${oldPHPshort}.log\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/var/log/qnap/phpfpm-stderr${oldPHPshort}.log\n\
stderr_logfile_maxbytes=0\nexitcodes=0\n" >> /etc/supervisor/conf.d/supervisor.conf; fi

# Set mailname
RUN echo "mydomain.com" > /etc/mailname

# Set locales
RUN echo -e 'en_US.UTF-8 UTF-8\nnl_NL.UTF-8 UTF-8' > /etc/locale.gen

# Run locales
RUN locale-gen

# Give www-data permissions
RUN usermod -s /bin/bash www-data && \
  usermod -a -G redis www-data && \
  chown redis:redis /etc/redis/redis.conf

# Create missing folders postfix
RUN mkdir /var/spool/postfix/hold && \
  chown -R postfix:root /var/spool/postfix/hold && \
  ln -s /etc/services /var/spool/postfix/etc/services


# Manually set the apache environment variables in order to get apache to work immediately.
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2.pid
ENV APACHE_RUN_DIR=/var/run/apache2
ENV LANGUAGE=en_US:en
ENV LANG=nl_NL.UTF-8
ENV LC_ALL=nl_NL.UTF-8

EXPOSE 80
EXPOSE 83
#EXPOSE 8080
#EXPOSE 8443

# Execute the apache daemon in the foreground so we can treat the container as an
# executeable and it wont immediately return.
CMD ["sh", "/start.sh"]
