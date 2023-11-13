FROM ubuntu:jammy

ENV TERM=linux

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        unzip \
        git \ 
        wget \
        nano \
        vim \
        zsh \
        #cron \
        php8.2-apcu \
        php8.2-cli \
        php8.2-curl \
        php8.2-mbstring \
        php8.2-opcache \
        php8.2-readline \
        php8.2-xml \
        php8.2-zip \
        php8.2-gd \
        php8.2-bcmath \ 
        php8.2-igbinary \ 
        php8.2-imagick \ 
        php8.2-intl \ 
        php8.2-mysql \ 
        php8.2-redis \ 
        php8.2-soap \ 
        php8.2-sqlite3 \ 
        php8.2-fpm \
        php-excimer \
    && apt-get clean

# Backup the original file
RUN cp /etc/adduser.conf /etc/adduser.conf.bak

# Change the value of DSHELL to /bin/zsh
RUN sed -i 's/^DSHELL=.*/DSHELL=\/bin\/zsh/' /etc/adduser.conf

RUN wget https://get.symfony.com/cli/installer -O - | bash
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer self-update

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* ~/.composer

COPY php-global-overrides.ini /etc/php/8.2/fpm/conf.d/z-overrides.ini
COPY php-global-overrides.ini /etc/php/8.2/cli/conf.d/z-overrides.ini
COPY overrides.conf /etc/php/8.2/fpm/pool.d/z-overrides.conf

#RUN wget http://pear.php.net/go-pear.phar; php go-pear.phar

RUN composer global config --no-plugins allow-plugins.dg/composer-frontline true
RUN composer global require dg/composer-frontline

STOPSIGNAL SIGQUIT

EXPOSE 9000

CMD ["/usr/sbin/php-fpm8.2", "-O" ]
