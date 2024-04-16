#ifndef WISHBONE_H
#define WISHBONE_H

#include <stdint.h>

/**
 * @brief Write data to a device on the wishbone interface
 * 
 * @param addr The address of the device
 * @param data Data to the device
 */
void wb_write(uint32_t addr, uint32_t data);

/**
 * @brief Read data from a device on the wishbone interface
 * 
 * @param addr The address of the device
 * @return uint32_t 
 */
uint32_t wb_read(uint32_t addr);

#endif