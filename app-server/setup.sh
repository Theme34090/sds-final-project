#!/bin/bash

sudo apt update -y
sudo apt install apache2 libapache2-mod-php7.4 \
php7.4-gd php7.4-mysql php7.4-curl php7.4-mbstring php7.4-intl \
php7.4-gmp php7.4-bcmath php-imagick php7.4-xml php7.4-zip -y

echo "downloading nextcloud"
cd /tmp
wget https://download.nextcloud.com/server/releases/nextcloud-22.2.3.tar.bz2 -q
tar -xjf nextcloud-22.2.3.tar.bz2

echo "copying files"
sudo cp -r nextcloud /var/www/
sudo chown www-data:www-data /var/www/nextcloud/ -R

echo "setup apache"
sudo cp /tmp/nextcloud.conf /etc/apache2/sites-available/nextcloud.conf
sudo a2ensite nextcloud.conf
sudo a2enmod rewrite headers env dir mime setenvif ssl
sudo systemctl restart apache2

echo "installing nextcloud"
sudo cp /tmp/storage.config.php /var/www/nextcloud/config/storage.config.php
cd /var/www/nextcloud
sudo -u www-data php occ maintenance:install --database "mysql" --database-host "10.0.3.10" \
--database-name "${database_name}"  --database-user "${database_user}" \
--database-pass "${database_pass}" --admin-user "${admin_user}" --admin-pass "${admin_pass}"

sudo -u www-data php occ config:system:set trusted_domains 0 --value=${public_ip}

echo "key: ${s3_key}"
echo "secret: ${s3_secret}"

echo "setup script finished"