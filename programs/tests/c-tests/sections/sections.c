#include "flexpret.h"
#include <stdlib.h>
#include <stdint.h>

#define TEXTDATA_INIT_VAL (41)
#define RODATA_INIT_VAL   (42)
#define SRODATA_INIT_VAL  (43)

// Adding '#' after the sections removes an assembler warning; see
// https://stackoverflow.com/questions/58455300/assembler-warning-with-gcc-warning-when-placing-data-in-text
const int32_t c_textdata __attribute__((section(".text.c#")))   = TEXTDATA_INIT_VAL;
const int32_t c_rodata __attribute__((section(".rodata.c#")))   = RODATA_INIT_VAL;
const int32_t c_srodata __attribute__((section(".srodata.c#"))) = SRODATA_INIT_VAL;

int32_t d_textdata __attribute__((section(".text.d#")))         = TEXTDATA_INIT_VAL;
int32_t d_rodata __attribute__((section(".rodata.d#")))         = RODATA_INIT_VAL;
int32_t d_srodata __attribute__((section(".srodata.d#")))       = SRODATA_INIT_VAL;

int32_t textdata __attribute__((section(".text#")))             = TEXTDATA_INIT_VAL;
int32_t rodata __attribute__((section(".rodata#")))             = RODATA_INIT_VAL;
int32_t srodata __attribute__((section(".srodata#")))           = SRODATA_INIT_VAL;


// Pass-by-value will copy it, losing the address
static inline void _print_addr_val(const int32_t *val)
{
    _fp_print((int) val);
    _fp_print(*val);
}

int main() {
    _print_addr_val(&c_textdata);
    _print_addr_val(&c_rodata);
    _print_addr_val(&c_srodata);

    _print_addr_val(&d_textdata);
    _print_addr_val(&d_rodata);
    _print_addr_val(&d_srodata);

    _print_addr_val(&textdata);
    _print_addr_val(&rodata);
    _print_addr_val(&srodata);

    assert(c_textdata == TEXTDATA_INIT_VAL);
    assert(c_rodata   == RODATA_INIT_VAL);
    assert(c_srodata  == SRODATA_INIT_VAL);

    assert(d_textdata == TEXTDATA_INIT_VAL);
    assert(d_rodata   == RODATA_INIT_VAL);
    assert(d_srodata  == SRODATA_INIT_VAL);

    assert(textdata == TEXTDATA_INIT_VAL);
    assert(rodata   == RODATA_INIT_VAL);
    assert(srodata  == SRODATA_INIT_VAL);
    
    return 0;
}
