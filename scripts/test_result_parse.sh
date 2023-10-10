#!/bin/bash

# Verify that the program started
echo "Parsing results from test: $1"

# if ! grep --quiet "Assertion failed: Program terminated sucessfully" $1; then
# echo "ERROR: Test program did not terminate properly"
# exit -1
# fi

if grep --quiet "ERROR:" $1; then
echo "ERROR: Test assertion failed"
exit -1
fi

echo "Test: $1 succeeded"