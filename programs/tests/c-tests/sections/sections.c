#include "flexpret.h"
#include <stdlib.h>

// Adding '#' after the sections removes the warning; see
// https://stackoverflow.com/questions/58455300/assembler-warning-with-gcc-warning-when-placing-data-in-text
const int srodata __attribute__((section(".text#"))) = 42;
int rodata __attribute__((section(".rodata#"))) = 43;


int main() {
    _fp_print(&srodata);
    _fp_print(&rodata);
    _fp_print(srodata);
    _fp_print(rodata);

    _fp_print(srodata);
    return 0;
}
