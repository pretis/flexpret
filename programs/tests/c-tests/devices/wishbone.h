#ifndef WISHBONE_H
#define WISHBONE_H

#define WB_BASE 0x40000000UL
#define WB_READ_ADDR (*( (volatile uint32_t *) (WB_BASE + 0x0UL)))
#define WB_WRITE_ADDR (*( (volatile uint32_t *) (WB_BASE + 0x4UL)))
#define WB_WRITE_DATA (*( (volatile uint32_t *) (WB_BASE + 0x8UL)))
#define WB_READ_DATA (*( (volatile uint32_t *) (WB_BASE + 0xCUL)))
#define WB_STATUS (*( (volatile uint32_t *) (WB_BASE + 0x10UL)))




#endif