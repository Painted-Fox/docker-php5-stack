# Full PHP5 stack:
#   * PHP5
#   * Nginx
#   * MariaDB
#   * Postfix

FROM ubuntu:precise
MAINTAINER Ryan Seto <ryanseto@yak.net>

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list && \
        apt-get update && \
        apt-get upgrade

# Ensure UTF-8
RUN apt-get update
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Install MariaDB from repository.
# Install PHP5, Nginx, and postfix.
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install python-software-properties && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
    add-apt-repository 'deb http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu precise main' && \
    apt-get update && \
    apt-get install -y mariadb-server \
    nginx \
    postfix \
    php5-fpm php5-mysql php-apc php5-imagick php5-imap php5-mcrypt php5-gd libssh2-php && \
    /etc/init.d/mysql stop

# Decouple our data from our container.
VOLUME ["/data"]

# Configure the database to use our data dir.
# Configure MariaDB to listen on any address.
RUN sed -i -e 's/^datadir\s*=.*/datadir = \/data/' /etc/mysql/my.cnf && \
    sed -i -e 's/^bind-address/#bind-address/' /etc/mysql/my.cnf

ADD nginx.conf /etc/nginx/nginx.conf
ADD https://raw.github.com/h5bp/server-configs-nginx/master/h5bp/expires.conf /etc/nginx/conf/expires.conf
ADD https://raw.github.com/h5bp/server-configs-nginx/master/h5bp/x-ua-compatible.conf /etc/nginx/conf/x-ua-compatible.conf
ADD https://raw.github.com/h5bp/server-configs-nginx/master/h5bp/cross-domain-fonts.conf /etc/nginx/conf/cross-domain-fonts.conf
ADD https://raw.github.com/h5bp/server-configs-nginx/master/h5bp/protect-system-files.conf /etc/nginx/conf/protect-system-files.conf
ADD nginx-site.conf /etc/nginx/sites-available/default
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini && \
    sed -i -e '/access_log/d' /etc/nginx/conf/expires.conf && \
    sed -i -e 's/^listen =.*/listen = \/var\/run\/php5-fpm.sock/' /etc/php5/fpm/pool.d/www.conf

# Decouple our data from our container.
VOLUME ["/srv/www"]

EXPOSE 80
ADD start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]