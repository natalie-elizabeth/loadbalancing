#!/bin/bash
set -o errexit
set -o pipefail


set_var() {
  HA_PROXY_PRIVATE_IP=$( gcloud compute instances list --format="value(networkInterfaces[0].networkIP)" --filter="name=('ha-proxy')" )
}

create_haproxy_users() {
  ###  create two users required by HAProxy for load balancing                         ###
  ### 'haproxy_check' will be used to check the status of a server.                    ###
  ### 'haproxy_root' is needed with root privileges to access the cluster from HAProxy ###
  echo 'About to create users to be used for load balancing....'

  sudo mysql -u "root" -p"${MYSQL_PASSWORD}" -Bse "CREATE USER 'haproxy_check'@'${HA_PROXY_PRIVATE_IP}';
  CREATE USER 'haproxy_root'@'${HA_PROXY_PRIVATE_IP}';
  GRANT ALL PRIVILEGES ON *.* TO 'haproxy_root'@'${HA_PROXY_PRIVATE_IP}';
  flush privileges;"

  echo 'Successfully created HAProxy users'
}


main() {
  set_var
  create_haproxy_users
}

main "$@"
