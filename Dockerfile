FROM ubuntu:trusty

RUN apt-get update \
	&& apt-get install python-software-properties

RUN add-apt-repository ppa:ondrej/php5-5.6

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
		libapache2-mod-php5 \
		php-pear php5-apcu php5-cli php5-common php5-curl php5-gd php5-imagick \
		php5-imap php5-intl php5-json php5-ldap php5-mongo php5-mysql php5-pgsql \
		php5-readline php5-tidy php5-xdebug php5-xsl php5-dev php5-intl php5-apcu php-http \
		libcurl4-openssl-dev libcurl3 libpcre3-dev make wget zip \
	&& pecl install pecl_http-1.7.6 \
	&& rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 \
	&& locale-gen en_US \
	&& locale-gen pt_BR \
	&& locale-gen pt_BR.UTF-8

RUN echo 'extension=http.so' > /etc/php5/mods-available/http.ini
RUN ln -sf ../../mods-available/http.ini /etc/php5/apache2/conf.d/20-http.ini

RUN a2enmod filter deflate mime expires rewrite \
	&& echo "ServerName localhost" > /etc/apache2/conf-enabled/fqdn.conf
	#&& ln -sf ../conf-enabled/fqdn.conf /etc/apache2/conf-enabled/fqdn.conf

COPY resources/etc/000-default /etc/apache2/sites-available/000-default.conf
RUN ln -sf ../sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf

COPY resources/etc/php5-additional.ini /etc/php5/mods-available/
RUN ln -s ../../mods-available/php5-additional.ini /etc/php5/apache2/conf.d/40-php5-additional.ini
RUN ln -s ../../mods-available/php5-additional.ini /etc/php5/cli/conf.d/40-php5-additional.ini

COPY resources/bin/apache2-foreground /usr/local/bin/
RUN chmod +x /usr/local/bin/apache2-foreground

# setup workdir
WORKDIR /var/www/html

CMD ["apache2-foreground"]
