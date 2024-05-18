#include <flexpret/wb.h>
#include <flexpret/time.h>

#define WB_BASE 0x40000000UL

struct WishboneBus {
    volatile uint32_t read_addr;
    volatile uint32_t write_addr;
    volatile uint32_t write_data;
    volatile uint32_t read_data;
    volatile uint32_t status;
};

#define WISHBONE_BUS ((struct WishboneBus *) (WB_BASE))

/**
 * About the NOP instructions:
 * 
 * The Wishbone bus needs two clock cycles between subsequenct read/write operations.
 * When the program is optimized with -Os, it will not adhere to this constraint.
 * Therefore we need to insert NOP instructions.
 * 
 * Note that the NOP instructions are not necessary in many cases. E.g., if 
 * the -O0 flag is passed, or if multiple hardware threads are running. Here we
 * assume the worst case to ensure it always works.
 * 
 * The while loops do not need any NOP instructions, because they compile to
 * a load followed by a branch instruction. Loads always an extra cycle.
 * 
 */

// Write and block until it was successful
// FIXME: Instead we could block until ready, then write?
void wb_write(uint32_t addr, uint32_t data) {
    WISHBONE_BUS->write_data = data;
    fp_nop;
    fp_nop;
    WISHBONE_BUS->write_addr = addr;
    fp_nop;
    fp_nop;
    while(!WISHBONE_BUS->status); // TODO: Move while up and remove !
}

uint32_t wb_read(uint32_t addr) {
    WISHBONE_BUS->read_addr = addr;
    fp_nop;
    fp_nop;
    while(!WISHBONE_BUS->status);
    return WISHBONE_BUS->read_data;
}
