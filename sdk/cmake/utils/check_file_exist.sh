# !/bin/bash
# Simple utility script for checking whether or not a file exists
# Used in CMake build system


# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
RED='\033[0;31m'
NC='\033[0m'

if ! [ -f $1 ]; then
    printf "${RED}${2}${NC}\n"
    exit 1
fi
