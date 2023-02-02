# `fp-cc`

`fp-cc` (FlexPRET Cycle Count) is a WIP tool that counts the number of cycles that 
a tagged piece of FlexPRET assembly code takes to execute, given its intended scheduling frequency.

The aim is to provide support for worst-case, as well as best-case, execution time
analysis.

##  1. How to Use `fp-cc`

### 1.1 Inputs

In the `c` FlexPRET program file, add labels as comments (annotations) to
indicate the region to analyze, as follows:
- `// @BEGIN CYCLE COUNT: <label>` at the beginning of the region,
- and `// @END CYCLE COUNT: <label>` at the end of the region.

Make sure the regions are structured blocks, that are blocks having a single point
of entry and a single point of exit. It is possible to indicate several regions
in one program.

FlexPRET compiler will then generate the dump file, one of the arguments needed
by `fp-cc` tool `fn`). The other two arguments are:
- the scheduling frequency `f`. It is an integer between 1 and 8, denoting a scheduling
frequency of `1/f`. Note that a scheduling frequency higher than 4 does not affect
the cycle count. The default value is `4`.
- the label `l`, which defaults to the empty string.

### 1.2 Execution
Before start, compile `.c` program to get teh `.dump` file.
In the command line, run the program as follows:
```
python3 -fn <path_to_the_dump_file> -f <frequency> - l <label>
```

Example of `test.c` program (under `test_programs/test.dump`). From the current 
folder, run:
```
cd test_programs/
make build
cd ..
python3 -fn 'test_programs/test.dump' -f 2 - l L2
```

### 1.3 Output
`fp-cc` outputs a parametrized (recursive) formula of the form:
```
formula = constant + [<cntL> + N x(formulaL) [+ <cntL2> + N x(formulaL2)] ...] + [<cntOR> OR <formulaOR> [+ <cntOR2> OR <formulaOR2>]] [+ <timingCst1> OR (<timingCst2> + delta)]
```

The formula is interpreted as a sum of constant numbers, plus loops (potentially
over formulas), plus if conditions (also potentially over formulas),
plus possible delays (due to timing instructions).

The worst-case execution number of cycles is obtained if we replace N with the
maximum number of loops, and assume all branches are taken. Similarly, the best-case execution number of cycles is obtained if we replace N with the minimum
number of loops and assume all branches are not taken. If the condition (if)
patterns are known, we can compute a precise value of the cycle count.

### 1.4 Example of how to interpret the output (formula)
Considering this example:
```
       // @BEGIN CYCLE COUNT: L2
       start_cycle = rdcycle();
       for (i = 0, sum = 0; i < N; i++) {
           if (i & (mask))
               sum++;
       }
       stop_cycle = rdcycle();
       // @END CYCLE COUNT: L2
```
`fp-cc` outputs the following formula under the scheduling frequency of `1/1`:
```
       18 + [(1 + N x (16 + [3 OR (5)]))]
```
while it outputs the following formula under the scheduling frequency of `1/4`:
```
       13 + [(1 + N x (10 + [1 OR (4)]))]
```


For a scheduling frequency of `1/1`, `100` iterations, and a `mask` value of `5`
(in such case, the `if` condition holds in `74` of the iterations), the cycle count is:
```
       18 + [(1 + N x (16 + [3 OR (5)]))]
               = 18+1+(16+3)*(100-74)+(16+5)*74
               = 2067
```
The experimental result (value read in `stop_cycle - start_cycle`) gives `2062`.
The extra cycles are due to the additional load and store instructions for writing
the result into the variable.

Similarly, for a scheduling frequency of `1/4` and the same input values, the cycle
count is:
```
       13 + [(1 + N x (10 + [1 OR (4)]))]
               = 13+1+(10+1)*(100-74)+(10+4)*74
               = 1336
```
The experimental result gives `1332`.

## 2. How it works

The tool parses the dump file to find the begin label. It processes each line,
where the assembly code is identified using a regular expression. The directed graph
is built gradually until the end label is reached.
Nodes of the directed graph are labeled after the instruction address (in hexadecimal).
Nodes also hold information about the instruction, such as the mnemonic and the
cycle count of the instruction.
All cycle counts are obtained, based on the scheduling frequency and derived from
Michael Zimmer's thesis. If a cycle count is inserted as an integer, then the cycle count for that instruction is that exact value. If, however, it is inserted as a string,
then the cycle count is either `1` __OR__ the value in the string.
This is taken into account while computing the cycle count.


## 3. Supported and Non-Supported Features

The currently supported features are:
- Nested loops and if conditions.
- Dump File, frequency, and label as arguments.
- It is possible to label several regions and perform the cycle count, one at a time.
- Currently, `fp-cc` takes into account timing instructions, but assumes they are
inserted using their mnemonic.

The currently non-supported features are:
- Function calls within the region
- Recursive function calls
- Identification of the loop bounds 
- Identification of infinite loops
- Identification of static conditions 


## 4. TODO List
- Build an independent FlexPRET compiler (instead of using RISC-V one + adding
using macros assembly instructions). This way, timing instructions are identified.
- What about interrupts?
- Add the non-supported features from the previous section.

