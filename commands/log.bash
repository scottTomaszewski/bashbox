#!/bin/bash

# log.bash

log.warn() {
    message="$1"
    echo "Log Warning: $message"
}

log.info() {
    message="$1"
    echo "Log Info: $message"
}

log.fatal() {
    message="$1"
    echo "Log Fatal: $message"
}
