#!/usr/bin/env python

# Run ISA test suite for different configurations
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

import subprocess
import sys
import re

baseDir = "."

target = "emulator"
#target = "fpga"

def testCmd(threads, flexpret, ispm, dspm, mul, suffix):
    return ["make",
        "TARGET=" + target,
        "THREADS=" + str(threads),
        "FLEXPRET=" + flexpret,
        "ISPM_KBYTES=" + str(ispm),
        "DSPM_KBYTES=" + str(dspm),
        "MUL=" + mul,
        "SUFFIX=" + suffix,
        "DEBUG=false",
        "PROG_DIR=isa"]

# Add tests.
tests = [
# min
testCmd(1,"false",16,16,"false","min"),
testCmd(4,"false",16,16,"false","min"),
testCmd(4,"true", 16,16,"false","min"),
## ex
testCmd(1,"false",16,16,"false","ex"),
testCmd(4,"false",16,16,"false","ex"),
testCmd(4,"true", 16,16,"false","ex"),
## ti
testCmd(1,"false",16,16,"false","ti"),
testCmd(4,"false",16,16,"false","ti"),
testCmd(4,"true", 16,16,"false","ti"),
## min
testCmd(1,"false",16,16,"true","min"),
testCmd(4,"false",16,16,"true","min"),
testCmd(4,"true", 16,16,"true","min"),
## ex
testCmd(1,"false",16,16,"true","ex"),
testCmd(4,"false",16,16,"true","ex"),
testCmd(4,"true", 16,16,"true","ex"),
## ti
testCmd(1,"false",16,16,"true","ti"),
testCmd(4,"false",16,16,"true","ti"),
testCmd(4,"true", 16,16,"true","ti"),
]


# Keep track of failed tests.
failedTests = []

# Execute all tests.
for test in tests:
    print "** RUNNING TEST: " + " ".join(test) + " **"
    try:
        lines = subprocess.check_output(test).splitlines()
        for line in lines:
            if re.search("FAILED", line):
                print line
                failedTests.append(line)
    except subprocess.CalledProcessError:
        failedTests.append(" ".join(test))

# Print results.
if failedTests:
    print "**** FAILED TESTS ****"
    for failedTest in failedTests:
        print failedTest
else:
    print "**** ALL TESTS PASSED ****"


