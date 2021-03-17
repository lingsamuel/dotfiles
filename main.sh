#!/bin/bash

SCRIPT_LOCATION="$(dirname $(readlink -f $0))"
# In bash/sh, `source XX.sh` $0 is bash/sh itself
if [[ -n ${BASH_SOURCE[0]} ]]; then
    SCRIPT_LOCATION="$( readlink -f "$( dirname "${BASH_SOURCE[0]}" )" )"
fi

if [[ $SHELL = *"zsh"* ]]; then
    # shellcheck source=./zsh.sh
    source "$SCRIPT_LOCATION/zsh.sh"
fi

# shellcheck source=./utils.sh
source "$SCRIPT_LOCATION/utils.sh"
# shellcheck source=./aliases.sh
source "$SCRIPT_LOCATION/aliases.sh"
# shellcheck source=./completion.sh
source "$SCRIPT_LOCATION/completion.sh"
# shellcheck source=./app.sh
source "$SCRIPT_LOCATION/app.sh"
