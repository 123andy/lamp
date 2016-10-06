FROM ubuntu:trusty
MAINTAINER Andy Martin <andy123@stanford.edu>
# FORKED FROM  https://github.com/tutumcloud/lamp / Fernando Mayo <fernando@tutum.co>, Feng Honglin <hfeng@tutum.co>

# Install packages
ENV DEBIAN_FRONTEND noninteractive

# Set DB 'admin' user password to REDCAP
ENV MYSQL_PASS redcap
#ENV APACHE_LOG_DIR


# Install packages
RUN apt-get update && \
  apt-get -y install supervisor \
  git \
  apache2 \
  libapache2-mod-php5 \
  mysql-server \
  php5-mysql \
  pwgen \
  php-apc \
  phpmyadmin \
  php5-curl \
  php5-gd \
  php5-mcrypt \
  nano \
  ssmtp \
  && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD supervisord-cron.conf /etc/supervisor/conf.d/supervisord-cron.conf

# Add a dummy html file
ADD index.html /var/www/html/index.html

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# enable mcrypt
RUN php5enmod mcrypt

# Configure /redcap_webroot as the webfolder
# RUN git clone https://github.com/fermayo/hello-world-lamp.git /app
# RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
# RUN mkdir -p /redcap_webroot && rm -fr /var/www/html && ln -s /redcap_webroot /var/www/html

# Make a link from /redcap_webroot to the real webroot.  This makes the mapped folder
RUN ln -s /var/www/html /redcap_webroot


#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 32M
ENV PHP_POST_MAX_SIZE 32M

# You must escape the / with a blackslash
ENV PHP_TIMEZONE "America\/Los_Angeles"

# Recommended by REDCap
ENV PHP_MAX_INPUT_VARS 10000

# Assumes REDCap is one dir down
ENV PHP_CRON_COMMAND "php /redcap_webroot/redcap/cron.php"

# Add mappable volumes
VOLUME  [ "/redcap_webroot", "/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306 8025
CMD ["/run.sh"]
