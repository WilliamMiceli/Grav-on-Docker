#!/bin/bash

set -e

function start_services() {
    echo "[ INFO ] Starting nginx"
    bash -c 'php5-fpm -D; nginx -g "daemon off;"'
}

function main() {
    start_services
}

main "$@"