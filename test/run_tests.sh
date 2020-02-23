#!/bin/bash
# Run FlexPRET unit tests.
set -ex
set -euo pipefail

./test/init.sh
./mill flexpret.test
