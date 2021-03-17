#!/bin/bash


# kubectl completion
if [[ ! -f $HOME/.k8s_completion.sh ]]; then
  kubectl completion zsh > $HOME/.k8s_completion.sh
fi
source $HOME/.k8s_completion.sh
if [[ ! -f $HOME/.k8s_completion.zsh ]]; then
  __kubectl_convert_bash_to_zsh > $HOME/.k8s_completion.zsh
  sed -i 's/<(__kubectl_convert_bash_to_zsh)/$HOME\/.k8s_completion.zsh/g' ./.k8s_completion.sh 
fi

# helm completion
if [[ ! -f $HOME/.helm_completion.sh ]]; then
  helm completion zsh > $HOME/.helm_completion.sh
fi
source $HOME/.helm_completion.sh


# stack completion
if [[ ! -f $HOME/.stack_completion.sh ]]; then
    stack --bash-completion-script stach > $HOME/.stack_completion.sh
fi
source $HOME/.stack_completion.sh
#eval "$(stack --bash-completion-script stack)"
