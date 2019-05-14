#!/bin/bash

set -o errexit

set -o pipefail

export DEBIAN_FRONTEND="noninteractive"

HAPROXY_SQL_ROOT_PASSWORD=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/haproxy_sql_root_password -H "Metadata-Flavor: Google")

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

setup_haproxy() {
  echo 'About to install and enable HAProxy....'

  sudo apt-get install haproxy -y

  # enable HAProxy...
  echo 'ENABLED=1' | sudo tee -a /etc/default/haproxy;

  echo 'Successfully installed HAProxy.'

  echo 'About to back up existing HAProxy config file...'
  sudo cp /etc/haproxy/haproxy.cfg{,.original}
  echo 'Done backing up existing config file.'

  sudo sed -i "s/.*mode*/# mode http/" /etc/haproxy/haproxy.cfg
  sudo sed -i "s/.*httplog*/# option httplog/" /etc/haproxy/haproxy.cfg

  echo '********Setup complete********'
}

turn_selinux_boolean_on() {
  echo 'About to turn on the haproxy_connect_any boolean....'

  sudo su
  echo exit 101 > /usr/sbin/policy-rc.d
  chmod +x /usr/sbin/policy-rc.d
  apt-get install policycoreutils -y
  rm -f /usr/sbin/policy-rc.d

  # turn on the haproxy_connect_any boolean so haproxy can connect to all TCP ports
  setsebool -P haproxy_connect_any on

  echo 'HAProxy can now connect to all TCP ports. Scipt completed successfully!'
}

main() {
    create_environment
    setup_haproxy
    turn_selinux_boolean_on
}

main "$@"