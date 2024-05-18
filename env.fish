# From: https://stackoverflow.com/questions/19672673/can-a-fish-script-tell-what-directory-its-stored-in
set -x FLEXPRET_ROOT (cd (dirname (status -f)); and pwd)
set -x PATH $PATH:$FLEXPRET_ROOT/build/emulator
set -x FP_PATH $FLEXPRET_ROOT
set -x FP_SDK_PATH $FLEXPRET_ROOT/sdk
