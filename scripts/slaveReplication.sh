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

  if [ $SLAVE_NAME = "slave2.0" ]; then
    SERVER_ID=2
  else
	SERVER_ID=3
  fi

  sudo sed -i "s/.*bind-address.*/bind-address = $INSTANCE_IP/" $CONFIG_FILE
  sudo sed -i "s/.*#server-id.*/server-id = $SERVER_ID/" $CONFIG_FILE

  sudo service mysql restart

  echo '********Successfully updated MySQL config file*********'

}