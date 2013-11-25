#!/bin/bash

# Stop on error
set -e

DATADIR="/data"
WEBDIR="/srv/www"

# test if DATADIR has content
if [ ! "$(ls -A $DATADIR)" ]; then
    echo "Initializing MariaDB at $DATADIR"
    # Copy the data that we generated within the container to the empty DATADIR.
    cp -R /var/lib/mysql/* $DATADIR
fi

# Ensure mysql owns the DATADIR
chown -R mysql $DATADIR
chown root $DATADIR/debian*.flag

# The password for 'debian-sys-maint'@'localhost' is auto generated.
# The database inside of DATADIR may not have been generated with this password.
# So, we need to set this for our database to be portable.
echo "Setting password for the 'debian-sys-maint'@'localhost' user"
/etc/init.d/mysql start
sleep 1
DB_MAINT_PASS=$(cat /etc/mysql/debian.cnf |grep -m 1 "password\s*=\s*"| sed 's/^password\s*=\s*//')
mysql -u root -e \
    "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS';"

# Create the superuser named 'docker'.
mysql -u root -e \
    "DELETE FROM mysql.user WHERE user = 'docker'; CREATE USER 'docker'@'localhost' IDENTIFIED BY 'docker'; GRANT ALL PRIVILEGES ON *.* TO 'docker'@'localhost' WITH GRANT OPTION; CREATE USER 'docker'@'%' IDENTIFIED BY 'docker'; GRANT ALL PRIVILEGES ON *.* TO 'docker'@'%' WITH GRANT OPTION;" && \

# Startup postfix
/etc/init.d/postfix start

# Ensure www-data owns the WEBDIR
chown -R www-data $WEBDIR

service php5-fpm start
/usr/sbin/nginx
