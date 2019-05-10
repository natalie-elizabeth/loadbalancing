#!bin/bash

set -o errexit
set -o pipefail

create_envrionment () {
  echo "**************Setup************"

  sudo apt-get update
  sudo apt-get install haproxy -y
  sudo mv /tmp/configs/haproxy.cfg /etc/haproxy/haproxy.cfg

  echo "*************** Restart Haproxy ***************"
  sudo systemctl restart haproxy
}

main () {
  create_envrionment
}

main "$@"