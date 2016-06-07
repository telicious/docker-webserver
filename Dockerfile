FROM ubuntu:latest
MAINTAINER Thomas Mueller <thomas-m@gmx.net>

ENV DEBIAN_FRONTEND noninteractive

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# add a Personal Package Archives (PPA)
# the PPA has changed. we need both ppa:ondrej/php and ppa:ondrej/php-qa
# add the repositories and install PHP7
RUN apt-get update && apt-get install software-properties-common -y --no-install-recommends -y \
    language-pack-en-base wget \
    && export LC_ALL=en_US.UTF-8 \
       export LANG=en_US.UTF-8 \
    && add-apt-repository ppa:ondrej/php \
    && add-apt-repository ppa:ondrej/php-qa \
    && apt-get update && apt-get install -y --no-install-recommends -y \
        make \
        mc \
        htop \
        mysql-server \
        mysql-client \
        apache2 \
        libapache2-mod-php7.0 \
        php7.0 php7.0-mysql php7.0-curl php7.0-gd php7.0-json php7.0-mcrypt php7.0-opcache php7.0-xml php7.0-intl \
        debconf-utils \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt-get --purge autoremove && apt-get clean

RUN rm -rf /var/www && \
    mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/httpdocs /var/www/log && \
    chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www && \
    chmod 777 /var/www/log

# enabled moduls ...
RUN a2enmod rewrite

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Update the default apache site with the config we created.
COPY apache2/apache2.conf /etc/apache2/sites-available/000-default.conf
COPY apache2/ports.conf /etc/apache2/ports.conf
RUN a2ensite 000-default.conf

RUN echo -e "\nexport TERM=xterm" >> ~/.bashrc

CMD /usr/sbin/apache2ctl -D FOREGROUND

