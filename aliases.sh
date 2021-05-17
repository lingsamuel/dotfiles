#!/bin/bash

## =====
## Shell & Commands
## =====

alias ll='ls -lih'
alias diff="diff --strip-trailing-cr"

# Copy to clipboard (Ctrl+V)
alias copy="xclip -selection clipboard"

# CMD-line usage:
# echo -n "abcd" | cs
# cv
alias cs="xclip"
alias cv="xclip -o"

alias first='awk "{print \$1}"'
alias second='awk "{print \$2}"'
alias final='awk "{print \$NF}"'

alias search="history|peco"

alias py='python'
alias py3='python3'
alias py2='python2'
alias share="python -m http.server "

alias kurl="curl --noproxy '*' -X POST -H 'Content-Type: application/json'"

alias untargz='tar xvzf'
alias untar='tar xvf'
alias targz='tar czvf'

alias svim='sudo vim'
alias vi='vim'
alias ea='vim ~/.zshrc'
alias ca='code ~/.zshrc'
alias apply='source ~/.zshrc'

# test proxy socks5
#alias tps="curl -x socks5://localhost:1080 --connect-timeout 5 https://google.com"
alias tps="curl --socks5-hostname 127.0.0.1:1080 https://google.com"
# test proxy http/https
alias tpt="curl -x http://localhost:1081 --connect-timeout 5 https://google.com"

give_me_permission() {
    chmod +x *.sh
}

alias e=exit
alias c=clear

alias tldr="tldr -t base16"

alias portusage="sudo lsof -i -P -n | grep LISTEN"

alias manuskript="$HOME/Projects/manuskript/bin/manuskript"
alias lint-zh="remark -u lint-zh"

#source /usr/share/nvm/init-nvm.sh
nvm_init() {
    source /usr/share/nvm/init-nvm.sh
}

## =====
## ArchLinux
## =====

alias pkg='sudo pacman -S'
alias pkgup='sudo pacman -Syu'
alias aur='yay -S'
alias pkgs='sudo pacman -Ss'
alias update="sudo pacman -Syu"

p_size() {
    pacman -Qi | gawk '/^Name/ { x = $3 }; /^Installed Size/ { sub(/Installed Size  *:/, ""); print x":" $0 }' | sort -k2,3nr | grep MiB
}
alias package_size=p_size

## =====
## Network
## =====

alias natrules='sudo iptables -t nat -nvL --line-numbers'
alias nat='sudo iptables -t nat'

setproxy() {
    local baseURL=${1:-'127.0.0.1'}
    export HTTP_PROXY="http://$baseURL:1081"
    export SOCKS_PROXY="socks5://$baseURL:1080"
    export socks_proxy=$SOCKS_PROXY

    export http_proxy=$HTTP_PROXY
    export HTTPS_PROXY=$HTTP_PROXY
    export https_proxy=$HTTP_PROXY

    export ALL_PROXY=$SOCKS_PROXY
    export all_proxy=$SOCKS_PROXY
}

setnonlocalproxy() {
    setproxy "$(hostip)"
}

setdockerproxy() {
    setproxy "$(hostip docker0)"
}

alias clearproxy="unset HTTP_PROXY; unset http_proxy; unset HTTPS_PROXY; unset https_proxy; unset SOCKS_PROXY; unset socks_proxy; unset ALL_PROXY; unset all_proxy;"

set_docker_proxy() {
    local CONF="$HOME/.docker/config.json"

    if [[ ! -f "${CONF}.bak" ]]; then
        echo "Backup $CONF => ${CONF}.bak"
        cp "$CONF" "${CONF}.bak"
    fi
    local DK0_PROXY="http://$(hostip docker0):1081"
    local V=$(cat "$CONF" | jq ".proxies.default={\"httpProxy\":\"$DK0_PROXY\",\"httpsProxy\":\"$DK0_PROXY\"}")
    echo "$V" >"$CONF"
}

unset_docker_proxy() {
    local CONF="$HOME/.docker/config.json"
    if [[ ! -f "${CONF}.bak" ]]; then
        echo "Backup $CONF => ${CONF}.bak"
        cp "$CONF" "${CONF}.bak"
    fi
    local DK0_PROXY="http://$(hostip docker0):1081"
    local V=$(cat "$CONF" | jq '.proxies.default={}')
    echo "$V" >"$CONF"
}

enable_docker_pull_proxy() {
    pushd /etc/systemd/system/docker.service.d/

    if [[ ! -f "proxy.conf.bak" ]]; then
        sudo cp proxy.conf proxy.conf.bak
    fi

    if [[ -n $HTTP_PROXY ]]; then
        echo "[Service]
Environment=\"HTTP_PROXY=$HTTP_PROXY\"
Environment=\"HTTPS_PROXY=$HTTP_PROXY\"" >> "/tmp/__proxy.conf"
        sudo mv "/tmp/__proxy.conf" ./proxy.conf

        sudo systemctl daemon-reload
        sudo systemctl restart docker
    else
        echo "HTTP_PROXY is emtpy!"
    fi
    popd
}

disable_docker_pull_proxy() {
    pushd /etc/systemd/system/docker.service.d/
    sudo rm proxy.conf
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    popd
}

## =====
## Docker
## =====

clearcontainer() {
    docker rm $(docker ps -aq)
}
alias cleardocker="docker images -qf dangling=true | xargs docker rmi"

export DOCKER_CONFIG=~/.docker
alias dk="docker"
alias dcls="docker container ls "

alias dockerrun="docker run -it --rm"
alias dr=dockerrun
alias dkr=dr

## =====
## Git
## =====

gitdiff(){
    local HASH=${1:-HEAD}
    local NUMS=${2:-1}
    git diff ${HASH}~${NUMS} ${HASH}
}

alias fixup="git commit -a --amend --no-edit -s"

commit() {
    local msg=${1:-"Update at $(date +"%Y-%m-%d")"}
    git add .
    git commit -S -sm "$msg"
}
unp() {
    commit $@
    git push
}

clone() {
    local REPO=("$@")

    normalize_url() {
        local URL=$1
        if [[ $URL = "git@"* ]]; then
            echo $URL
        elif [[ $URL = "https://"* ]]; then
            echo $URL
        else
            echo "git@github.com:$URL.git"
        fi
    }

    for r in "${REPO[@]}"; do
        local GIT_REPO=$(normalize_url $r)
        echo "Cloning $GIT_REPO"
        git clone $GIT_REPO
    done
}

## Gerrit
gerrit_push() {
    git push origin HEAD:refs/for/$(git branch -v | grep \* | awk '{print $2}')%submit
}
alias review=gerrit_push

## =====
## Hugo
## =====

alias hs="hugo server --buildDrafts -w -t beautifulhugo --ignoreCache"
alias hb="hugo -d public --buildDrafts -t beautifulhugo --ignoreCache"

new() {
    local USAGE=(echo "Usage:
  new_post <type> <path>
Will use .template.md and .env.sh
Options:
  <type> post|review|feed
  -r     Generate file name without date (or env NO_DATE_FILENAME=true)
")

    # 检查 post type
    local POST_TYPE=$1
    if [[ -z $POST_TYPE ]]; then
        $USAGE
        return
    fi
    if [[ $POST_TYPE = "post" ]]; then
        POST_TYPE="page"
    fi
    shift
    local HUGO_DIR="$HOME/Articles/lingsamuel.github.io/content/$POST_TYPE"
    if [[ ! -d $HUGO_DIR ]]; then
        $USAGE
        echo "Post type $POST_TYPE not found in dir $HUGO_DIR"
        return
    fi

    if [[ -f $HUGO_DIR/.env.sh ]]; then
        source $HUGO_DIR/.env.sh
    fi

    # 检查 dir/dir/title
    if [[ -z $1 ]] || [[ $1 = "-"* ]]; then
        $USAGE
        return
    fi

    # 检查 -r 参数
    local NO_DATE_FILENAME=${NO_DATE_FILENAME:-"false"}

    OPTIND=2
    while getopts ":r" opt; do
        case "${opt}" in
        r)
            NO_DATE_FILENAME="true"
            ;;
        *)
            $USAGE
            return
            ;;
        esac
    done

    # 生成 文件夹名和 post title
    local TITLE=$(basename "$1")
    local DIR_NAME=$(dirname "$1")
    mkdir -p $DIR_NAME
    local FILE_NAME=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr '`~!@#$%^&*()+=[]{}|\\:";<>,.?/ ' '-' | tr "'" '-')

    if [[ $NO_DATE_FILENAME = "false" ]]; then
        FILE_NAME="$(date +"%Y-%m-%d")-$FILE_NAME"
    fi

    if [[ ! $FILE_NAME = *".md" ]]; then
        FILE_NAME="$FILE_NAME.md"
    fi
    FILE_NAME="${DIR_NAME}/${FILE_NAME}"

    if [[ -f $FILE_NAME ]]; then
        echo "File exists!"
        return
    fi

    # 生成文件
    cd $HUGO_DIR

    local DATE_STR=$(date +"%Y-%m-%dT%H:%M:%S%z")

    if [[ -f "${DIR_NAME}/.template.md" ]]; then
        echo "Using template ${DIR_NAME}/.template.md"
        cat "${DIR_NAME}/.template.md" | DATE_STR="$DATE_STR" TITLE="$TITLE" envsubst >>"$FILE_NAME"
    else
        echo "Generating $FILE_NAME ..."
        cat <<EOF >>"$FILE_NAME"
---
title: "$TITLE"
subtitle: ""
date: $DATE_STR
categories: []
tags: []
aliases: []
draft: true
---



<!--more-->

EOF
    fi

    code $FILE_NAME
    popd
}

## =====
## Helm + Kubernetes + Minikube
## =====

init_k8s_symlinks() {
    pushd ~/Projects/kubernetes
    local DIRS=("api" "apiextensions-apiserver" "apimachinery" "apiserver" "cli-runtime" "client-go" "cloud-provider" "cluster-bootstrap" "code-generator" "component-base" "component-helpers" "controller-manager" "cri-api" "csi-translation-lib" "kube-aggregator" "kube-controller-manager" "kube-proxy" "kube-scheduler" "kubectl" "kubelet" "legacy-cloud-providers" "metrics" "mount-utils" "sample-apiserver" "sample-cli-plugin" "sample-controller")

    local FROM_DIR="../../staging/src/k8s.io"
    local TO_DIR="./vendor/k8s.io"
    for dir in ${DIRS[@]}; do
        ln -s "$FROM_DIR/$dir" "$TO_DIR/$dir"
    done
    popd
}

del_k8s_symlinks() {
    pushd ~/Projects/kubernetes
    local DIRS=("api" "apiextensions-apiserver" "apimachinery" "apiserver" "cli-runtime" "client-go" "cloud-provider" "cluster-bootstrap" "code-generator" "component-base" "component-helpers" "controller-manager" "cri-api" "csi-translation-lib" "kube-aggregator" "kube-controller-manager" "kube-proxy" "kube-scheduler" "kubectl" "kubelet" "legacy-cloud-providers" "metrics" "mount-utils" "sample-apiserver" "sample-cli-plugin" "sample-controller")

    local TO_DIR="./vendor/k8s.io"
    for dir in ${DIRS[@]}; do
        rm -r "$TO_DIR/$dir"
    done
    popd
}

ssh_minikube() {
    local ID=${1:-""}
    if [[ ! $ID = "" ]]; then
        ID="-m$ID"
    fi
    local PROFILE=${2:-"minikube"}
    local DIR="$HOME/.minikube/machines/${PROFILE}${ID}"
    local IP=$(jq -r ".Driver.IPAddress" "$DIR/config.json")
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i "$DIR/id_rsa" docker@$IP
}

alias hupdate='helm repo update'
alias hls='helm search repo --devel'

# kubectl aliases
source $HOME/Projects/kubectl-life-saver/generator.sh

## =====
## Golang
## =====

export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

export GO111MODULE=on
export GOOS="linux"
export GOARCH="amd64"
#alias gosetup="go list -m -json -mod=mod all; go mod tidy"
alias gosetup="go list -m -json -mod=mod all; go mod download"
