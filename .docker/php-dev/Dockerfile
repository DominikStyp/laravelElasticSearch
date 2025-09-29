FROM dockerwest/php-laravel:7.3
COPY prepare-command.sh /prepare-command.sh
# RUN apt-get update > /dev/null && apt-get install -y rsync default-mysql-client procps net-tools acl > /dev/null

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      rsync default-mysql-client procps net-tools acl \
      php7.3-xml libxml2 \
 && rm -rf /var/lib/apt/lists/*

# install nodejs
#RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
#    apt-get update && apt-get install -y nodejs

# Install yarn
#RUN apt-get install apt-transport-https && \
#    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
#    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
#    apt-get update && apt-get install --no-install-recommends yarn

ENV PHP_IDE_CONFIG "serverName=application"
COPY xdebug.ini /etc/php/7.3/mods-available/xdebug.ini

# wee need this extensions for mailparse and other plugins for PHP
# RUN apt-get install -y php-mbstring php-xml > /dev/null




WORKDIR /var/www/html
