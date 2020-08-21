FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive

ENV TZ=America/New_York

ENV WORDPRESS_VERSION 5.1.1

ENV HOME /root

CMD ["/sbin/my_init"]

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN     export LANG=en_US.UTF-8 \
         && apt-get update \
	  && apt-get install software-properties-common -y\
        && add-apt-repository -y ppa:ondrej/php \
        && apt-get update \
        && apt-get install -y --allow-unauthenticated --no-install-recommends \
                apache2 \
                php7.0 \
                libapache2-mod-php7.0 \
                php7.0-ssh2 \
                php7.0-bcmath \
                php7.0-cli \
                php7.0-ldap \
                php7.0-curl \
                php7.0-gd \
                php7.0-mbstring \
                php7.0-mcrypt \
                php7.0-json \
                php7.0-mysql \
                php7.0-xml \
                php7.0-xmlrpc \
                php7.0-gettext \
                php7.0-soap \
                php7.0-readline \
                php7.0-odbc \
                php7.0-zip \
                php7.0-sybase \
                php7.0-intl \
                php7.0-redis \
                subversion \
                git \
                curl \
                zip \
                unzip \
                acl \
                wget \
                nano \
                openssl \
                freetds-common \
        && apt-get -y clean \
        && rm -rf /var/lib/apt/lists/*

RUN     COMPOSER_HOME=/usr/local/composer curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN     a2dismod mpm_event \
        && a2enmod mpm_prefork rewrite vhost_alias headers ssl speling setenvif

COPY site.conf /home/config/site.conf
COPY phpinfo.conf /home/config/phpinfo.conf


RUN     mkdir -p /etc/service/apache \
        && mkdir -p /home/phpinfo

COPY phpinfo.php /home/phpinfo/index.php

COPY mssql.so /usr/lib/php/20131226/mssql.so

COPY apache2-foreground /etc/service/apache/run
COPY apache2.conf /etc/apache2/apache2.conf
COPY site.conf /home/config/site.conf

RUN     mkdir /home/drive \
        && mkdir /home/logs \
        && chmod +x /etc/service/apache/run
        
RUN     curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" \
        && tar -xzf wordpress.tar.gz \
        && rm wordpress.tar.gz \
        && mv  wordpress /home/drive/ 
        
COPY test.html /home/drive/wordpress/
       
EXPOSE 80
