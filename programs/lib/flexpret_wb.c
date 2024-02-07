#include "flexpret_wb.h"
#include "flexpret_time.h"

#define WB_BASE 0x40000000UL

struct WishboneBus {
    volatile uint32_t read_addr;
    volatile uint32_t write_addr;
    volatile uint32_t write_data;
    volatile uint32_t read_data;
    volatile uint32_t status;
};

#define WISHBONE_BUS ((struct WishboneBus *) (WB_BASE))

// Write and block until it was successful
// FIXME: Instead we could block until ready, then write?
void wb_write(uint32_t addr, uint32_t data) {
    WISHBONE_BUS->write_data = data;
    WISHBONE_BUS->write_addr = addr;
    while(!WISHBONE_BUS->status);
}

volatile uint32_t wb_read(uint32_t addr) {
    WISHBONE_BUS->read_addr = addr;
    
    /**
     * @brief When the compiler is passed the -Os flag to optimize the program,
     *        it will compile to a store immediately followed by a load instruction
     *        on the bus. However, the wishbone bus needs two instructions between
     *        a load and store. This is the reason these NOP instructions are 
     *        inserted.
     * 
     *        When the -O0 flag is passed the code will work without the NOP
     *        instructions because non-optimal instructions are present between
     *        the load and store.
     */
    fp_nop;
    fp_nop;
    while(!WISHBONE_BUS->status);
    return WISHBONE_BUS->read_data;
}
