
#include <stdint.h>
#include <flexpret_io.h>
#include "wishbone.h"


void wb_write(uint32_t addr, uint32_t data) {
    WB_WRITE_DATA = data;
    WB_WRITE_ADDR = addr;
    while(!WB_STATUS) {}
}

uint32_t wb_read(uint32_t addr) {
    WB_READ_ADDR = addr;
    while(!WB_STATUS) {}
    return WB_READ_DATA;
}

int main() {
    uint32_t read;    
    wb_write(1, 42);
    read = wb_read(1);
    _fp_print(read);
    return 0;
}
