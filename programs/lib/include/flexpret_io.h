#ifndef FLEXPRET_IO_H
#define FLEXPRET_IO_H

#include <stdint.h>
#include <stdbool.h>
#include <flexpret_assert.h>
#include <flexpret_csrs.h>
#include <flexpret_types.h>


// Write a generic value to the tohost CSR
static inline void write_tohost(uint32_t val) { write_csr(CSR_TOHOST, val); }


// Print the given value in the simulation
static inline void _fp_print(uint32_t val) {
  while(swap_csr(CSR_HWLOCK, 1) == 0);
  write_csr(CSR_TOHOST, 0xbaaabaaa);
  write_csr(CSR_TOHOST, val);
  swap_csr(CSR_HWLOCK, 0);
}

// Finish/stop the simulation. Simulation environment will terminate when all
//  cores have made a call to `_fp_finish`
static inline void _fp_finish() {
  write_csr(CSR_TOHOST, 0xdeaddead);
}

// Abort simulation. Simulation environment will terminate if any core makes this call
// FIXME: Get line number which triggered abort also out
static inline void _fp_abort() {
  write_csr(CSR_TOHOST, 0xdeadbeef);
}


// GPO ports, if port width < 32, then upper bits ignored
// CSR_GPO_*
// Write all GPO bits


static inline void gpo_write_1(uint32_t val) {
  write_csr(CSR_UARCH5, val);
}

static inline void gpo_write(uint32_t port, uint32_t val) {
  switch(port) {
    case 0: write_csr(CSR_UARCH4, val); break;
    case 1: write_csr(CSR_UARCH5, val); break;
    case 2: write_csr(CSR_UARCH6, val); break;
    case 3: write_csr(CSR_UARCH7, val); break;
    default: _fp_abort();
  }
}

static inline void gpo_set(uint32_t port, uint32_t mask) {
  switch(port) {
    case 0: set_csr(CSR_UARCH4, mask); break;
    case 1: set_csr(CSR_UARCH5, mask); break;
    case 2: set_csr(CSR_UARCH6, mask); break;
    case 3: set_csr(CSR_UARCH7, mask); break;
    default: _fp_abort();
  }
}

// For each '1' bit in mask, set corresponding GPO bit to '0'
static inline void gpo_clear(uint32_t port, uint32_t mask) {
  switch(port) {
    case 0: clear_csr(CSR_UARCH4, mask); break;
    case 1: clear_csr(CSR_UARCH5, mask); break;
    case 2: clear_csr(CSR_UARCH6, mask); break;
    case 3: clear_csr(CSR_UARCH7, mask); break;
    default: _fp_abort();
  }
}

static inline uint32_t gpo_read(uint32_t port) {
  switch(port) {
    case 0: return read_csr(CSR_UARCH4); break;
    case 1: return read_csr(CSR_UARCH5); break;
    case 2: return read_csr(CSR_UARCH6); break;
    case 3: return read_csr(CSR_UARCH7); break;
    default: _fp_abort();
  }
}

// FIXME: Write the remaining gpi_read functions
static inline uint32_t gpi_read_1() {
  return read_csr(CSR_UARCH1);
}

// GPI ports, if port width < 32, then upper bits are zero
// Read GPI bits
// CSR_GPI_*
static inline uint32_t gpi_read(uint32_t port) {
  switch(port) {
    case 0: return read_csr(CSR_UARCH0); break;
    case 1: return read_csr(CSR_UARCH1); break;
    case 2: return read_csr(CSR_UARCH2); break;
    case 3: return read_csr(CSR_UARCH3); break;
    default: _fp_abort();
  }
}


#endif // FLEXPRET_IO_H
