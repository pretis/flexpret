#!/usr/bin/env bash

# From https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script 
FLEXPRET_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export PATH="$FLEXPRET_ROOT/build/emulator:$PATH"
export FP_PATH="$FLEXPRET_ROOT"
export FP_SDK_PATH="$FLEXPRET_ROOT/sdk"
