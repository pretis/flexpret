# From: https://stackoverflow.com/questions/19672673/can-a-fish-script-tell-what-directory-its-stored-in
set FLEXPRET_ROOT (cd (dirname (status -f)); and pwd)

set DIR (cd (dirname (status -f)); and pwd) 
set PATH $PATH:$FLEXPRET_ROOT/build/emulator
set FP_PATH $FLEXPRET_ROOT
set FP_SDK_PATH $FLEXPRET_ROOT/sdk
