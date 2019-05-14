#!/usr/bin/env bash

# script to install mysql-server and configure server as a master

# exit when a command fails
set -o errexit

# exit if previous command returns a non 0 status
set -o pipefail

export DEBIAN_FRONTEND="noninteractive"

CONFIG_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"
MYSQL_PASSWORD=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/sql_root_password -H "Metadata-Flavor: Google")
SLAVE_UNAME=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/slave_username -H "Metadata-Flavor: Google")
SLAVE_PASSWORD=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/slave_password -H "Metadata-Flavor: Google")


# update available packages
create_environment() {
    echo "*******Updating packages*******"

    sudo apt update -y
    sudo apt-get upgrade -y

    echo "*******Setup Mysql*************"

    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_PASSWORD}"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_PASSWORD}"

    sudo apt-get install mysql-server -y

    echo '********Successfully installed MySQL.********'
}

update_config_file() {
  echo '***************Updating mysqld.cnf**************'
  
  #update bind address, server-id and log_bin values
  sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" $CONFIG_FILE
  sudo sed -i '/server-id/s/^#//g' $CONFIG_FILE
  sudo sed -i '/log_bin/s/^#//g' $CONFIG_FILE

  sudo service mysql restart

  echo '********Successfully updated MySQL config file*********'
}

create_replication_user() {
  echo '******Create user to be used for replication*******'

  sudo mysql -u "root" -p"${MYSQL_PASSWORD}" -Bse "CREATE USER '${SLAVE_UNAME}'@'%' identified by '${SLAVE_PASSWORD}';
  GRANT REPLICATION slave ON *.* TO '${SLAVE_UNAME}'@'%';"

  echo '***********Successfully created replication user*********'
}

create_test_data() {
  echo '********Create data for testing replication******'

  sudo mysql -u "root" -p"${MYSQL_PASSWORD}" -Bse "CREATE DATABASE musicians;
  CREATE TABLE musicians.rock (name varchar(20));
  INSERT INTO musicians.rock values ('Daughtry');"

  echo '***********Successfully created replication test data***********'
}

main() {
  create_environment
  update_config_file
  create_replication_user
  create_test_data
}

main "$@"
