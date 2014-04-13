# Compilation configuration for malardalen WCET suite.
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

#MAX_CYCLES = 2000000
PROG ?=\
adpcm\
bs\
bsort100\
cnt\
compress\
cover\
crc\
duff\
expint\
fac\
fdct\
fibcall\
insertsort\
janne_complex\
jfdctint\
lcdnum\
loop3\
ns\
matmult\
statemate \
nsichneu\

C = 1

$(DEFAULT_RULES)
