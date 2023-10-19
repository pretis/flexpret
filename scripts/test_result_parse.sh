#!/bin/bash

# if ! grep --quiet "Assertion failed: Program terminated sucessfully" $1; then
# echo "ERROR: Test program did not terminate properly"
# exit -1
# fi

# if grep --quiet "ERROR:" $1; then
# echo "ERROR: Test assertion failed"
# exit -1
# fi

any_failed=0

red_bold='\033[1;31m'         # Red
green_bold='\033[1;32m'       # Green
color_off='\033[0m'           # Text Reset

if [ $2 -eq 0 ]
then
    echo -e "${green_bold}Test: $1 succeeded ${color_off}"
else
    echo -e "${red_bold}Test: $1 failed with exit code ${2} ${color_off}"
    any_failed=1
fi

exit $any_failed
