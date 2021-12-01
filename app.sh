#!/bin/bash


save_image() {
  set -ex
  docker save $1 -o /tmp/__$2.img
  targz ./$2.tar.gz /tmp/__$2.img
  rm /tmp/__$2.img
  set +ex
}

#eval $(thefuck --alias)


# 列出 Pods
# 参数 1: namespace
# 参数 2: grep 名称
getpod() {
    kubectl get pods -n $2 | grep $1 | awk '{print NR ": " $s}'
}

# describe Pod
# 参数 1: namespace
# 参数 2: grep 名称
# 参数 3: 行数
descpod() {
    POD_NAME=$( (getpod $1 $2) | sed -n "$3"p | awk '{print $2}')
    kubectl describe -n $2 pod $POD_NAME
}


# Interactive K8s Describe
ikd() {
	ns=$(kubectl get ns | peco | awk '{print $1}')
	if [[ -z $ns ]]; then
		echo "Aborted."
		return 0
	fi

	rs=$(kubectl api-resources | peco | awk '{print $1}')
    if [[ -z $rs ]]; then
        echo "Aborted."
        return 0
    fi

	name=$(kubectl get $rs -o wide -n $ns | peco | awk '{print $1}')
	if [[ ! -z $name ]]; then
		kubectl describe -n $ns $rs $pod
	else
		echo "Aborted."
	fi
}


grab_failed_k8_image() {
    #set -x    
    ns=${1:-'default'}
    prefix=${2:-'docker.io'}
    images=$(kubectl get pods -n $ns | grep ImagePull | awk '{print $1}' | kubectl describe pod -n $ns | grep -i pulling | awk '{print $NF}' | sed 's/"//g' | sed "s/$prefix\///g" | sed "s/\\n/\n/g" | sort | uniq)
    if [[ -z $images ]]; then
        echo "empty result, nothing to do, abort."
        return 0;
    fi

    tagged_images=$(echo $images | awk "{print \"$prefix/\"\$1}")
    echo $images | awk "{print \"$prefix/\"\$1}"
    echo "To pull images:"
    echo $images
    while read image; do
        echo "pulling $image..."
        #docker pull $image
        #docker tag $image $prefix/$image
    done <<< $images
    img_name=/tmp/${3:-"$1-$2.img"}
    
    img_oneline=$(echo $tagged_images | sed -z 's/\n/ /g')
    
    set -x    
    echo "==="
    echo "tagged: $tagged_images"
    echo "storing $img_oneline..."
    echo "storing images to $img_name..."
    docker save $(echo "$img_oneline") -o $img_name
}

restart_sogou(){
    sudo ps -ef|grep sogou|grep -v grep|awk '{print $2}'|xargs kill -9
    sudo ps -ef|grep fcitx|grep -v grep|awk '{print $2}'|xargs kill -9
    fcitx &
}
soft_link_paper_icon_raw_to_cd() {
    ln_icon() {
      scale="$1"
      pushd /usr/share/icons/Paper/$scale/mimetypes
      sudo ln -sf application-x-cd-image.png application-x-raw-disk-image.png
      popd
    }
    ln_icon 16x16@2x
    ln_icon 16x16
    ln_icon 24x24@2x
    ln_icon 24x24
    ln_icon 32x32@2x
    ln_icon 32x32
    ln_icon 48x48@2x
    ln_icon 48x48
    ln_icon 512x512@2x
    ln_icon 512x512
}


alias ud="tmux split-window"
alias lr="tmux split-window -h"

co() {
    for dir in $(ls -d */); do
        echo "$dir:"
        loc $dir $@
        echo "\n\n"
    done
}

co_tofile() {
    FILE=codelines.txt
    if [[ -f $FILE ]]; then
        FILE=$(mktemp codelines.XXXX.txt)
    fi
    echo "" > $FILE;
    for dir in $(ls -d */);do 
        echo "$dir" >> $FILE; 
        loc $dir >> $FILE; 
        echo "\n\n" >> $FILE; 
    done
}

shellutils() {
    code /home/lingsamuel/Projects/shell-utils/
}

split_file_to_paste() {
  local filepath=$1
  if [[ ! -f $filepath ]]; then
    echo "not such file $filepath"
    return 1
  fi
  local filename=$(basename $filepath)
  split -db 100m $filepath "${filename}."
}

test_go_templates() {
  mkdir -p .helm_test/templates
  cd .helm_test
  cat << 'EOF' >> Chart.yaml
apiVersion: v2
name: "Test GO Templates"
description: ""
type: application
version: "0.1.0"
appVersion: "0.1.0"


EOF

  cat << 'EOF' >> values.yaml

EOF
}


start_prometheus(){
  sudo systemctl start prometheus prometheus-blackbox-exporter prometheus-node-exporter grafana
  sudo systemctl enable prometheus prometheus-blackbox-exporter prometheus-node-exporter grafana
}

stop_prometheus(){
  sudo systemctl stop prometheus prometheus-blackbox-exporter prometheus-node-exporter grafana
  sudo systemctl disable prometheus prometheus-blackbox-exporter prometheus-node-exporter grafana
}

start_sonarqube(){
  sh ~/sonarqube-8.1.0.31237/bin/linux-x86-64/sonar.sh console
}
