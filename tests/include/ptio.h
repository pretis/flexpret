#include "encoding.h"

#define EMULATOR_ADDR 0xFFFFFF00
#define debug_string(s) emulator_outputstr(s);
//#define debug_string(s) printf("%s", s);
//#define debug_string(s) uart_outputstr(s);

#define gpio_set(mask) (set_csr(uarch2, mask))
#define gpio_clear(mask) (clear_csr(uarch2, mask))
#define gpio_write(val) ({write_csr(uarch2, val);})
#define gpio_read() (read_csr(uarch2))

// Write each character in the string to a pre-defined address.
void emulator_outputstr(char* str) {
    volatile char* addr = (char*) EMULATOR_ADDR;
    while(*str != 0) {
        *addr = *str;
        str++;
    }
}

// Convert number to string in hex format
char qbuf[9];
char* itoa_hex(n)
unsigned int n;
{
    register int i;
    for(i = 7; i >= 0; i--) {
        qbuf[i] = (n & 15) + 48;
        if(qbuf[i] >= 58) {
            qbuf[i] += 7;
        }
        n = n >> 4;
    }
    qbuf[8] = '\0';
    return(qbuf);
}
