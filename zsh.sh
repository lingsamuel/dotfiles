#!/bin/zsh

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish


#bindkey -M emacs $(tput kDC5) kill-word # ctrl-delete
bindkey '5~' kill-word # control delete
bindkey '^H' backward-kill-word # control backspace
bindkey '3~' kill-word # alt delete


bindkey "\e[1;3D" backward-word ### Alt left
bindkey "^[[1;2D" backward-word ### Shift left
bindkey "\e[1;3C" forward-word ### Alt right
bindkey "^[[1;2C" forward-word ### Shift right



widget_git-status() {
  zle kill-whole-line
  zle -U "git status"
  zle accept-line
}

zle -N widget_git-status
bindkey '^[OQ' widget_git-status

# ZLE Widget
autocomment() {
  local CONTENT="$BUFFER"
  if [[ ${#CONTENT} = "0" ]]; then
    return;
  fi

  local CONTENT_ARRAY
  IFS=$'\n' CONTENT_ARRAY=("${(@f)CONTENT}")

  local COMMENT_MODE="uncomment"
  for ((i = 1; i <= ${#CONTENT_ARRAY[@]}; i++)); do
    if [[ ! ${CONTENT_ARRAY[$i]} = "#"* ]]; then
      COMMENT_MODE="comment"
      break
    fi
  done

  local LINE_NUMBER=1
  local CHARS_POS=0
  for ((i = 1; i <= ${#CONTENT_ARRAY[@]}; i++)); do
    CHARS_POS=$(( CHARS_POS + ${#CONTENT_ARRAY[$i]} + 1 ))
    if (( $CHARS_POS <= $CURSOR )); then
      LINE_NUMBER=$((LINE_NUMBER + 1))
    fi
    if [[ $COMMENT_MODE = "comment" ]]; then
      # if [[ ! "${CONTENT_ARRAY[$i]}" = "#"* ]]; then
        CONTENT_ARRAY[$i]="#${CONTENT_ARRAY[$i]}"
      # fi
    else
      # if [[ "${CONTENT_ARRAY[$i]}" = "#"* ]]; then
        CONTENT_ARRAY[$i]="${CONTENT_ARRAY[$i]:1}"
      # fi
    fi
  done
  if [[ $COMMENT_MODE = "uncomment" ]]; then
    CURSOR=$((CURSOR - LINE_NUMBER))
  fi
  BUFFER=$(join_array $'\n' "${CONTENT_ARRAY[@]}")
  if [[ $COMMENT_MODE = "comment" ]]; then
    CURSOR=$((CURSOR + LINE_NUMBER))
  fi
}

autocomment_singleline() {
  local CONTENT="$BUFFER"
  if [[ ${#CONTENT} = "0" ]]; then
    return;
  fi
  # echo "\nCURSOR_POS: $CURSOR"
  if [[ "$CONTENT" = "#"* ]]; then
    CURSOR=$((CURSOR - 1))
    BUFFER="${CONTENT:1}"
  else
    BUFFER="#$BUFFER"
    CURSOR=$((CURSOR + 1)) # 移动光标位置
  fi
  # # zle _zsh_highlight
}
# zle -N _zsh_highlight
zle -N autocomment
zle -N autocomment_singleline
bindkey '^_' autocomment # ^_ is <Ctrl+/>
# bindkey '^_' autocomment_singleline
