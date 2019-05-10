#!/bin/bash

set -o errexit
set -o pipefail

function print_env_error(){
    echo "variables.sh file not found in this directory,"
}