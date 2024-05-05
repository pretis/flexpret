# From: https://stackoverflow.com/questions/19672673/can-a-fish-script-tell-what-directory-its-stored-in
set -g FLEXPRET_ROOT (cd (dirname (status -f)); and pwd)
set -g PATH $PATH:$FLEXPRET_ROOT/build/emulator
set -g FP_PATH $FLEXPRET_ROOT
set -g FP_SDK_PATH $FLEXPRET_ROOT/sdk
