#!/bin/bash

set -o errexit
set -o pipefail

export DEBIAN_FRONTEND="noninteractive"
MYSQL_PASSWORD=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/sql_root_password -H "Metadata-Flavor: Google")

create_environment() {
  echo "*******Updating packages*******"

  sudo apt update -y
  sudo apt-get upgrade -y

  echo "*******Setup Mysql*************"

  sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_PASSWORD}"
  sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_PASSWORD}"

  sudo apt-get install mysql-server -y

  echo '********Successfully installed MySQL*********'
}

main() {
    create_environment
}

main "$@"
