#!/bin/bash

iface() {
    route | grep default | awk '{print $NF}'
}

hostip() {
    if [[  -v GLOBAL_PROXY_ADDR ]]; then
        echo "$GLOBAL_PROXY_ADDR"
    fi
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
    curl --noproxy "*" "https://api.ip.sb/geoip/${1}" -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0'
}
alias geoip=curl_geoip
