#!/usr/bin/env python
import subprocess
import sys
import re

baseDir = "."

# Construct command for a test.
def testCmd(loc, cycles, t, f, i, d, smul, stats, exc, gt, du, ee):
    return ["make", "run", 
            "PROG_DIR=" + loc,
            "MAX_CYCLES=" + str(cycles),
            "THREADS=" + str(t),
            "FLEX=" + str(f).lower(),
            "ISPM_KBYTES=" + str(i),
            "DSPM_KBYTES=" + str(d),
            "MUL_STAGES=" + str(smul),
            "STATS=" + str(stats).lower(),
            "EXCEPTIONS=" + str(exc).lower(),
            "GET_TIME=" + str(gt).lower(),
            "DELAY_UNTIL=" + str(du).lower(),
            "EXCEPTION_ON_EXPIRE=" + str(ee).lower(),
            "PROG_CONFIG=emulator",
            "TARGET=emulator",
            "DEBUG=false"]

# Add tests.
tests = []
cycles = 100000

# Regression
# Baseline
tests.append(testCmd("asm-sodor", cycles, 1, False,  16, 16, 1, False, False, False, False, False))
tests.append(testCmd("asm-sodor", cycles, 4, False,  16, 16, 1, False, False, False, False, False))
tests.append(testCmd("asm-sodor", cycles, 8, False,  16, 16, 1, False, False, False, False, False))
tests.append(testCmd("asm-sodor", cycles, 1, False,  16, 16, 2, False, False, False, False, False))
tests.append(testCmd("asm-sodor", cycles, 4, False,  16, 16, 2, False, False, False, False, False))
tests.append(testCmd("asm-sodor", cycles, 8, False,  16, 16, 2, False, False, False, False, False))
# FlexPRET
tests.append(testCmd("asm-sodor", cycles, 4,  True,  16, 16, 1, False, False, False, False, False))
tests.append(testCmd("asm-sodor", cycles, 8,  True,  16, 16, 1, False, False, False, False, False))
tests.append(testCmd("asm-sodor", cycles, 4,  True,  16, 16, 2, False, False, False, False, False))
tests.append(testCmd("asm-sodor", cycles, 8,  True,  16, 16, 2, False, False, False, False, False))
# FlexPRET w/ gt-du
tests.append(testCmd("asm-sodor", cycles, 4,  True,  16, 16, 1, False, False,  True,  True, False))
tests.append(testCmd("asm-sodor", cycles, 8,  True,  16, 16, 1, False, False,  True,  True, False))
tests.append(testCmd("asm-sodor", cycles, 4,  True,  16, 16, 2, False, False,  True,  True, False))
tests.append(testCmd("asm-sodor", cycles, 8,  True,  16, 16, 2, False, False,  True,  True, False))
# FlexpRET w/ gt-ee
tests.append(testCmd("asm-sodor", cycles, 4,  True,  16, 16, 1, False,  True,  True, False,  True))
tests.append(testCmd("asm-sodor", cycles, 8,  True,  16, 16, 1, False,  True,  True, False,  True))
tests.append(testCmd("asm-sodor", cycles, 4,  True,  16, 16, 2, False,  True,  True, False,  True))
tests.append(testCmd("asm-sodor", cycles, 8,  True,  16, 16, 2, False,  True,  True, False,  True))
# FlexPRET w/ gt-du-ee
tests.append(testCmd("asm-sodor", cycles, 4,  True,  16, 16, 1, False,  True,  True,  True,  True))
tests.append(testCmd("asm-sodor", cycles, 8,  True,  16, 16, 1, False,  True,  True,  True,  True))
tests.append(testCmd("asm-sodor", cycles, 4,  True,  16, 16, 2, False,  True,  True,  True,  True))
tests.append(testCmd("asm-sodor", cycles, 8,  True,  16, 16, 2, False,  True,  True,  True,  True))

# Keep track of failed tests.
failedTests = []

# Execute all tests.
for test in tests:
    print "********** RUNNING TEST: " + " ".join(test) + " **********"
    proc = subprocess.Popen(test, cwd=baseDir, stdout=subprocess.PIPE)
    for line in iter(proc.stdout.readline,""):
        sys.stdout.write(line)
        if re.search("\[ FAILED \]", line):
            failedTests.append(line)
    proc.wait()

# Print results.
if failedTests:
    print "********** FAILED TESTS **********"
    for failedTest in failedTests:
        sys.stdout.write(failedTest)
else:
    print "********** ALL TESTS PASSED **********"

