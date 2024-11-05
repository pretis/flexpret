#!/usr/bin/env bash

# From https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script 
# The top solution does not work on macOS.
# The solution below comes from this answer: https://stackoverflow.com/a/179231
pushd . > '/dev/null';
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}";

while [ -h "$SCRIPT_PATH" ];
do
    cd "$( dirname -- "$SCRIPT_PATH"; )";
    SCRIPT_PATH="$( readlink -f -- "$SCRIPT_PATH"; )";
done

cd "$( dirname -- "$SCRIPT_PATH"; )" > '/dev/null';
SCRIPT_PATH="$( pwd; )";
popd  > '/dev/null';

FLEXPRET_ROOT=$SCRIPT_PATH
export PATH="$FLEXPRET_ROOT/build/emulator:$PATH"
export FP_PATH="$FLEXPRET_ROOT"
export FP_SDK_PATH="$FLEXPRET_ROOT/sdk"
