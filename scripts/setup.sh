#!/bin/bash

set -o errexit
set -o pipefail

source helper.sh
[ -f "variables.sh" ] || (print_env_error && exit 1)
source variables.sh

create_environment() {
    echo "*******Updating packages*******"
    sudo apt-get update -y

    echo "*******Setup Mysql*************"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_PASSWORD}"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_PASSWORD}"
    sudo apt-get install mysql-server -y

    echo "*******Clean up**********"
    mysql_secure_installation
    echo '********Successfully installed MySQL.********'
}

main() {
    create_environment
}
main "$@"