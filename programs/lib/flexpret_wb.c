#include "flexpret_wb.h"

#define WB_BASE 0x40000000UL
#define WB_READ_ADDR (*( (volatile uint32_t *) (WB_BASE + 0x0UL)))
#define WB_WRITE_ADDR (*( (volatile uint32_t *) (WB_BASE + 0x4UL)))
#define WB_WRITE_DATA (*( (volatile uint32_t *) (WB_BASE + 0x8UL)))
#define WB_READ_DATA (*( (volatile uint32_t *) (WB_BASE + 0xCUL)))
#define WB_STATUS (*( (volatile uint32_t *) (WB_BASE + 0x10UL)))

// Write and block until it was successful
// FIXME: Instead we could block until ready, then write?
void wb_write(uint32_t addr, uint32_t data) {
    WB_WRITE_DATA = data;
    WB_WRITE_ADDR = addr;
    while(!WB_STATUS);
}

uint32_t wb_read(uint32_t addr) {
    WB_READ_ADDR = addr;
    while(!WB_STATUS);
    return WB_READ_DATA;
}
