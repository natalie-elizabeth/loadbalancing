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
    packer build packer/master/packer.json
    echo 
}