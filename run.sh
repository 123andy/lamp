#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

echo "=> Setting timezone"
sed -ri -e "s/^;?\s?date\.timezone.*/date\.timezone = ${PHP_TIMEZONE}/" /etc/php5/apache2/php.ini

echo "=> Setting max_input_vars"
sed -ri -e "s/^;?\s?max_input_vars.*/max_input_vars = ${PHP_MAX_INPUT_VARS}/" /etc/php5/apache2/php.ini

echo "=> Setting php sendmail to ssmtp"
sed -ri -e "s/^;?\s?sendmail_path.*/sendmail_path = \/usr\/sbin\/ssmtp -t/" /etc/php5/apache2/php.ini

echo "=> Setting ssmtp link to mailhog"
sed -ri -e "s/^mailhub.*/mailhub=mailhog:1025/" /etc/ssmtp/ssmtp.conf

echo "=> Configuring CRON"
crontab -l | { cat; echo "* * * * * ${PHP_CRON_COMMAND} > /dev/null"; } | crontab -


echo "=> Starting Supervisor"
exec supervisord -n -c "/etc/supervisor/supervisord.conf"
