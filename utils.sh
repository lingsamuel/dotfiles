#!/bin/bash

iface() {
    route | grep default | awk '{print $NF}'
}

hostip() {
    TARGET=${1:-$(iface)}
    ip -o -4 addr list "$TARGET" | awk '{print $4}' | cut -d/ -f1
}

mymac() {
    ip a | grep -A 1 "$(iface)" | grep link/ether | awk '{print $2}'
}
myip4() {
    ip a | grep -A 1 "$(iface)" | grep inet | awk '{print $2}'
}

mkcdir() {
    mkdir -p -- "$1" &&
        cd -P -- "$1" || return
}

alias mc=mkcdir

curl_geoip() {
    echo "Curling https://api.ip.sb/geoip/${1}"
    curl --noproxy "*" "https://api.ip.sb/geoip/${1}"
}
alias geoip=curl_geoip
