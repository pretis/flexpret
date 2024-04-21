/**
 * @file sections.c
 * @author Magnus Mæhlum (magnusmaehlum@outlook.com)
 * 
 * This test checks that data put in the different sections work as expected.
 * It both prints the addresses and values of the data put in the sections.
 * 
 * Notably, data put in the .text section stays in the instruction memory,
 * which is not byte addressible.
 * 
 */

#include <flexpret/flexpret.h>

#include <stdlib.h>
#include <stdint.h>

#define TEXTDATA_INIT_VAL (41)
#define RODATA_INIT_VAL   (42)
#define SRODATA_INIT_VAL  (43)
#define ARRAY_INIT_VAL    { 0x11, 0x22, 0x33, 0x44 }

// Adding '#' after the sections removes an assembler warning; see
// https://stackoverflow.com/questions/58455300/assembler-warning-with-gcc-warning-when-placing-data-in-text
const int32_t c_textdata __attribute__((section(".text.c#")))   = TEXTDATA_INIT_VAL;
const int32_t c_rodata __attribute__((section(".rodata.c#")))   = RODATA_INIT_VAL;
const int32_t c_srodata __attribute__((section(".srodata.c#"))) = SRODATA_INIT_VAL;

static int32_t d_textdata __attribute__((section(".text.d#")))         = TEXTDATA_INIT_VAL;
static int32_t d_rodata __attribute__((section(".rodata.d#")))         = RODATA_INIT_VAL;
static int32_t d_srodata __attribute__((section(".srodata.d#")))       = SRODATA_INIT_VAL;

int32_t textdata __attribute__((section(".text.i#")))           = TEXTDATA_INIT_VAL;
int32_t rodata __attribute__((section(".rodata.i#")))           = RODATA_INIT_VAL;
int32_t srodata __attribute__((section(".srodata.i#")))         = SRODATA_INIT_VAL;

// A byte array in .text is a bad idea, since the instruction memory (IMEM) is not
// byte adressable. We should expect that indexing this array yields the same
// word for all four indicies.
uint8_t arraytext[4] __attribute__((section(".text.a#")))       = ARRAY_INIT_VAL;

// If the linker script is set up properly, .rodata and .srodata should be placed
// in .data, i.e., the data memory (DMEM) and therefore be byte addressable.
uint8_t arrayrodata[4] __attribute__((section(".rodata.a#")))   = ARRAY_INIT_VAL;
uint8_t arraysrodata[4] __attribute__((section(".srodata.a#"))) = ARRAY_INIT_VAL;


// Pass-by-value will copy it, losing the address
static inline void _print_addr_val(const int32_t *val)
{
    printf("word has address %p and value %i\n", val, (int) *val);
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

    fp_assert(c_textdata == TEXTDATA_INIT_VAL, "Const value not properly set\n");
    fp_assert(c_rodata   == RODATA_INIT_VAL, "Const value not properly set\n");
    fp_assert(c_srodata  == SRODATA_INIT_VAL, "Const value not properly set\n");

    fp_assert(d_textdata == TEXTDATA_INIT_VAL, "Static value not properly set\n");
    fp_assert(d_rodata   == RODATA_INIT_VAL, "Static value not properly set\n");
    fp_assert(d_srodata  == SRODATA_INIT_VAL, "Static value not properly set\n");

    fp_assert(textdata == TEXTDATA_INIT_VAL, "Value not properly set\n");
    fp_assert(rodata   == RODATA_INIT_VAL, "Value not properly set\n");
    fp_assert(srodata  == SRODATA_INIT_VAL, "Value not properly set\n");

    // Need to add volatile here, otherwise compiler will resolve the checks at
    // compile time since all values are available
    const volatile uint8_t array[4] = ARRAY_INIT_VAL;

    for (uint32_t i = 0; i < sizeof(arraytext); i++) {
        // Expect the array to have the same value for all indicies; see earlier
        // for explanation
        fp_assert(
            arraytext[i] == (
                (array[0] <<  0) | 
                (array[1] <<  8) |
                (array[2] << 16) |
                (array[3] << 24)
            ), "Array in .text not word indexed as expected\n"
        );
    }

    for (uint32_t i = 0; i < sizeof(arrayrodata); i++) {
        fp_assert(arrayrodata[i] == array[i], "Array in .rodata incorrect\n");
    }

    for (uint32_t i = 0; i < sizeof(arraysrodata); i++) {
        fp_assert(arraysrodata[i] == array[i], "Array in .srodata incorrect\n");
    }
    
    return 0;
}
