#!/bin/bash

set -o errexit
set -o pipefail

validate_packer_mages() {
    packer validate packer/master/packer.json
    packer validate packer/slaves/packer.json
    packer validate packer/ha_proxy/packer.json
}

build_master_image() {
    touch master_build_output.log
    packer build packer/master/packer.json 2>&1 | tee master_build_output.log
    MASTER_TAG="$(grep 'Master image tag:' master_build_output.log | cut -d' ' -f8)"
    echo $MASTER_TAG
}

build_slave1_image() {
    touch slave1_build_output.log
    export IMAGE_NAME="slave1"
    packer build packer/slaves/packer.json 2>&1 | tee slave1_build_output.log
    SLAVE1_TAG="$(grep 'Slave1 image tag:' slave1_build_output.log | cut -d' ' -f8)"
    echo $SLAVE1_TAG
}

build_slave2_image() {
    touch slave2_build_output.log
    export IMAGE_NAME="slave2"
    packer build packer/slaves/packer.json 2>&1 | tee slave2_build_output.log
    SLAVE2_TAG="$(grep 'Slave2 image tag:' slave2_build_output.log | cut -d' ' -f8)"
    echo $SLAVE2_TAG
}

build_haproxy_image() {
    touch haproxy_build_output.log
    packer build packer/ha_proxy/packer.json 2>&1 | tee haproxy_build_output.log
    HAPROXY_TAG="$(grep 'Haproxy image tag:' haproxy_build_output.log | cut -d' ' -f8)"
    echo $HAPROXY_TAG
}

main() {
    #validate_packer_mages
    #build_master_image
    #build_slave1_image
    #build_slave2_image
    build_haproxy_image
}

main "$@"