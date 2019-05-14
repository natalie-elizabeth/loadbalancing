#!/bin/bash

set -o errexit
set -o pipefail

source variables.sh

validate_packer_mages() {
    packer validate packer/master/packer.json
    packer validate packer/slaves/packer.json
    packer validate packer/haproxy/packer.json
}

build_master_image() {
    touch master_build_output.log
    export IMAGE_NAME="db-lb-slave1"
    packer build packer/master/packer.json 2>&1 | tee master_build_output.log
    MASTER_TAG="$(grep 'A disk image was created:' master_image_output.log | cut -d' ' -f8)"
    echo $MASTER_TAG
}

build_slave1_image() {
    touch slave1_build_output.log
    packer build packer/slaves/packer.json 2>&1 | tee slave1_build_output.log
    SLAVE1_TAG="$(grep 'A disk image was created:' slave1_build_output.log | cut -d' ' -f8)"
    echo $SLAVE1_TAG
}

build_slave2_image() {
    touch slave2_build_output.log
    packer build packer/slaves/packer.json 2>&1 | tee slave2_build_output.log
    SLAVE2_TAG="$(grep 'A disk image was created:' slave2_build_output.log | cut -d' ' -f8)"
    echo $SLAVE2_TAG
}