#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

add-apt-repository -y ppa:ondrej/php

apt-get -y update
apt-get -y upgrade

apt-get install -y mysql-server mysql-client

apt-get -y install php7.1 apache2 libapache2-mod-php7.1
apt-get -y install php7.1-mysql php7.1-curl php7.1-dev php7.1-gd php7.1-intl php-pear php-imagick php7.1-imap php7.1-mcrypt php7.1-tidy php7.1-xmlrpc php7.1-xsl php7.1-mbstring php-gettext
apt-get -y install gcc make autoconf libc-dev pkg-config git zip build-essential curl
chown -R www-data:www-data /var/www/

cp /vagrant/vagrant/silex.local.conf /etc/apache2/sites-available/silex.local.conf

# Enable displaying of errors (no need to look at error log then, only for dev)
sudo sed -i.bak s/"display_errors = Off"/"display_errors = On"/g /etc/php/7.1/apache2/php.ini

a2enmod rewrite
a2ensite silex.local
service apache2 restart

# Install Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

# Set up database
mysql -uroot -proot -e "CREATE DATABASE silex_dev";
mysql -uroot -proot silex_dev -e "CREATE TABLE blog_posts (id int AUTO_INCREMENT PRIMARY KEY, title VARCHAR(128), content VARCHAR(1024), date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP);";
mysql -uroot -proot silex_dev -e "INSERT INTO blog_posts (title, content) VALUES ('Our First Blog Post', 'Not much here...');"