#!/bin/bash

set -o errexit

set -o pipefail

export DEBIAN_FRONTEND="noninteractive"

CONFIG_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"
SLAVE_NAME=$( curl http://metadata.google.internal/computeMetadata/v1/instance/name -H "Metadata-Flavor: Google" )
MYSQL_PASSWORD=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/sql_root_password -H "Metadata-Flavor: Google")
SLAVE_UNAME=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/slave_username -H "Metadata-Flavor: Google")
SLAVE_PASSWORD=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/slave_password -H "Metadata-Flavor: Google")
INSTANCE_IP=$( gcloud compute instances list --format="value(networkInterfaces[0].networkIP)" --filter="name=($SLAVE_NAME)" )
MASTER_HOST=$( gcloud compute instances list --format="value(networkInterfaces[0].networkIP)" --filter="name=('master')" )

update_config_file() {
  echo "*******Update mysql config file*******"

  if [ $SLAVE_NAME = "slave2" ]; then
    SERVER_ID=2
  else
	SERVER_ID=3
  fi

  sudo sed -i "s/.*bind-address.*/bind-address = $INSTANCE_IP/" $CONFIG_FILE
  sudo sed -i "s/.*#server-id.*/server-id = $SERVER_ID/" $CONFIG_FILE
  sudo service mysql restart

  echo '********Successfully updated MySQL config file*********'

}

setup_slave_replication() {
  echo "Setting up slave replication"

  sudo mysql -uroot  -p"${MYSQL_PASSWORD}" -Bse "CHANGE MASTER TO MASTER_HOST='${MASTER_HOST}',
  MASTER_USER='${SLAVE_UNAME}',
  MASTER_PASSWORD='${SLAVE_PASSWORD}';"

  echo 'Successfully set up slave replication'
}

restore_data_from_master_dump() {
  echo "About to restore data from dump..."

  sudo mysql -uroot -p"${MYSQL_PASSWORD}" < masterdbdump.sql

  echo "Successfully restored data from dump"
}

start_slave() {
  echo 'About to start slave...'

  sudo mysql -uroot  -p"${MYSQL_PASSWORD}" -Bse "start slave;"

  echo 'Successfully started slave'
}

### refresh users' privileges in the slave servers so that the priveleges of ###
### the HAProxy users replicated onto the slaves can be effected.            ###
refresh_users_priveleges() {
  echo 'About to refresh privileges for HAProxy users...'

  sudo mysql -u "root" -p"${MYSQL_PASSWORD}" -Bse "flush privileges;"

  echo 'Done refreshing privileges for HAProxy users.'
}

check_replication_status() {
  echo 'About to check replication status...'

  # Wait for slave to get started and have the correct status
  sleep 2

  SLAVE_OK=$(sudo mysql -uroot -p"${MYSQL_PASSWORD}" -e "SHOW SLAVE STATUS\G;" | grep 'Waiting for master')
  if [ -z "$SLAVE_OK" ]; then
	echo "ERROR! Wrong slave IO state."
  else
	echo "Slave IO state OK"
  fi

  echo 'Completed check for replication status'
}

main() {
  update_config_file
  setup_slave_replication
  restore_data_from_master_dump
  start_slave
  refresh_users_priveleges
  check_replication_status
}

main "$@"
