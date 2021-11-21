#!/bin/bash

sudo apt update -y
sudo apt install mariadb-server -y

sudo /etc/init.d/mysql start
sudo mysql -e "CREATE USER '${database_user}'@'%' IDENTIFIED BY '${database_pass}'; \
CREATE DATABASE IF NOT EXISTS ${database_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci; \
GRANT ALL PRIVILEGES ON ${database_name}.* TO '${database_user}'@'%'; \
FLUSH PRIVILEGES;"
echo $'[mysqld]\nskip-bind-address' | sudo tee -a /etc/mysql/my.cnf
sudo /etc/init.d/mysql restart

echo "setup script completed"
