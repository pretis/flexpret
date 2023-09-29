#ifndef FLEXPRET_IO_H
#define FLEXPRET_IO_H

#include <stdint.h>
#include "flexpret_csrs.h"

#define CSR_TOHOST_PRINTF (0xffffffff)
#define CSR_TOHOST_PRINT_INT (0xbaaabaaa)

static inline void write_tohost_tid(uint32_t, uint32_t);

static inline void write_tohost(uint32_t val) {
  int tid = read_hartid();
  write_tohost_tid(tid, val);
}

// Abort simulation. Simulation environment will terminate if any core makes this call
// FIXME: Get line number which triggered abort also out
static inline void _fp_abort(void) {
  write_tohost(0xdeadbeef);
}

// Write a generic value to the tohost CSR
static inline void write_tohost_tid(uint32_t tid, uint32_t val) {
  switch(tid) {
    case 0: write_csr(CSR_TOHOST(0), val); break;
    case 1: write_csr(CSR_TOHOST(1), val); break;
    case 2: write_csr(CSR_TOHOST(2), val); break;
    case 3: write_csr(CSR_TOHOST(3), val); break;
    case 4: write_csr(CSR_TOHOST(4), val); break;
    case 5: write_csr(CSR_TOHOST(5), val); break;
    case 6: write_csr(CSR_TOHOST(6), val); break;
    case 7: write_csr(CSR_TOHOST(7), val); break;
    default: _fp_abort();
  }
}

// Print the given value in the simulation
static inline void _fp_print(uint32_t val) {
  int tid = read_hartid();
  // while(swap_csr(CSR_HWLOCK, 1) == 0);
  write_tohost_tid(tid, CSR_TOHOST_PRINT_INT);
  write_tohost_tid(tid, val);
  // swap_csr(CSR_HWLOCK, 0);
}

// Finish/stop the simulation
static inline void _fp_finish(void) { 
  write_tohost(0xdeaddead);
}

// GPO ports, if port width < 32, then upper bits ignored
// CSR_GPO_*
// Write all GPO bits
static inline void gpo_write(uint32_t port, uint32_t val) {
  switch(port) {
    case 0: write_csr(CSR_UARCH4, val); break;
    case 1: write_csr(CSR_UARCH5, val); break;
    case 2: write_csr(CSR_UARCH6, val); break;
    case 3: write_csr(CSR_UARCH7, val); break;
    default: _fp_abort();
  }
}

static inline void gpo_write_0(uint32_t val) { write_csr(CSR_UARCH4, val); }
static inline void gpo_write_1(uint32_t val) { write_csr(CSR_UARCH5, val); }
static inline void gpo_write_2(uint32_t val) { write_csr(CSR_UARCH6, val); }
static inline void gpo_write_3(uint32_t val) { write_csr(CSR_UARCH7, val); }

static inline void gpo_set(uint32_t port, uint32_t mask) {
  switch(port) {
    case 0: set_csr(CSR_UARCH4, mask); break;
    case 1: set_csr(CSR_UARCH5, mask); break;
    case 2: set_csr(CSR_UARCH6, mask); break;
    case 3: set_csr(CSR_UARCH7, mask); break;
    default: _fp_abort();
  }
}

static inline void gpo_set_0(uint32_t mask) { set_csr(CSR_UARCH4, mask); }
static inline void gpo_set_1(uint32_t mask) { set_csr(CSR_UARCH5, mask); }
static inline void gpo_set_2(uint32_t mask) { set_csr(CSR_UARCH6, mask); }
static inline void gpo_set_3(uint32_t mask) { set_csr(CSR_UARCH7, mask); }

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

static inline void gpo_clear_0(uint32_t mask) { clear_csr(CSR_UARCH4, mask); }
static inline void gpo_clear_1(uint32_t mask) { clear_csr(CSR_UARCH5, mask); }
static inline void gpo_clear_2(uint32_t mask) { clear_csr(CSR_UARCH6, mask); }
static inline void gpo_clear_3(uint32_t mask) { clear_csr(CSR_UARCH7, mask); }

static inline uint32_t gpo_read(uint32_t port) {
  switch(port) {
    case 0: return read_csr(CSR_UARCH4); break;
    case 1: return read_csr(CSR_UARCH5); break;
    case 2: return read_csr(CSR_UARCH6); break;
    case 3: return read_csr(CSR_UARCH7); break;
    default: _fp_abort();
  }
}

static inline uint32_t gpo_read_0() { return read_csr(CSR_UARCH4); }
static inline uint32_t gpo_read_1() { return read_csr(CSR_UARCH5); }
static inline uint32_t gpo_read_2() { return read_csr(CSR_UARCH6); }
static inline uint32_t gpo_read_3() { return read_csr(CSR_UARCH7); }

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

static inline uint32_t gpi_read_0() { return read_csr(CSR_UARCH0); }
static inline uint32_t gpi_read_1() { return read_csr(CSR_UARCH1); }
static inline uint32_t gpi_read_2() { return read_csr(CSR_UARCH2); }
static inline uint32_t gpi_read_3() { return read_csr(CSR_UARCH3); }

#endif
