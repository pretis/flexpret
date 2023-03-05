#ifndef FLEXPRET_IO_H
#define FLEXPRET_IO_H

#include <stdint.h>
#include <flexpret_csrs.h>

// Write a generic value to the tohost CSR
void write_tohost(uint32_t val);

// Print the given value in the simulation
void _fp_print(uint32_t val);

// Finish/stop the simulation
void _fp_finish();

// GPO ports, if port width < 32, then upper bits ignored
// CSR_GPO_*
// Write all GPO bits
void gpo_write_0(uint32_t val);
void gpo_write_1(uint32_t val);
void gpo_write_2(uint32_t val);
void gpo_write_3(uint32_t val);

// For each '1' bit in mask, set corresponding GPO bit to '1'
void gpo_set_0(uint32_t mask);
void gpo_set_1(uint32_t mask);
void gpo_set_2(uint32_t mask);
void gpo_set_3(uint32_t mask);

// For each '1' bit in mask, set corresponding GPO bit to '0'
void gpo_clear_0(uint32_t mask);
void gpo_clear_1(uint32_t mask);
void gpo_clear_2(uint32_t mask);
void gpo_clear_3(uint32_t mask);

// Read GPO bits
uint32_t gpo_read_0();
uint32_t gpo_read_1();
uint32_t gpo_read_2();
uint32_t gpo_read_3();

// GPI ports, if port width < 32, then upper bits are zero
// Read GPI bits
// CSR_GPI_*
uint32_t gpi_read_0();
uint32_t gpi_read_1();
uint32_t gpi_read_2();
uint32_t gpi_read_3();

#endif // FLEXPRET_IO_H
