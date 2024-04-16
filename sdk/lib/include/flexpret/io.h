#ifndef FLEXPRET_IO_H
#define FLEXPRET_IO_H

#include <stdint.h>
#include <csrs>
#include <printf/printf.h>

#define CSR_TOHOST_PRINTF (0xffffffff)
#define CSR_TOHOST_FINISH (0xdeaddead)
#define CSR_TOHOST_ABORT  (0xdeadbeef)

#define PRINTF_COLOR_RED   "\x1B[31m"
#define PRINTF_COLOR_GREEN "\x1B[32m"
#define PRINTF_COLOR_NONE  "\x1B[0m"

static inline void write_tohost_tid(uint32_t, uint32_t);

static inline void write_tohost(uint32_t val) {
  int tid = read_hartid();
  write_tohost_tid(tid, val);
}

#define _fp_abort(fmt, ...) do { \
  printf("%s: %s: %i: " PRINTF_COLOR_RED "Abort:" PRINTF_COLOR_NONE, __FILE__, __func__, __LINE__); \
  printf(fmt, ##__VA_ARGS__); \
  write_tohost(CSR_TOHOST_ABORT); \
} while(0)

#define _fp_finish() do { \
  printf("%s: %i: " PRINTF_COLOR_GREEN "Finish\n" PRINTF_COLOR_NONE, __FILE__, __LINE__); \
  write_tohost(CSR_TOHOST_FINISH); \
} while(0)

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
    default: _fp_abort("Invalid thread id: %i\n", tid);
  }
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
    default: _fp_abort("Invalid port: %i\n", port);
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
    default: _fp_abort("Invalid port: %i\n", port);
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
    default: _fp_abort("Invalid port: %i\n", port);
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
    default: _fp_abort("Invalid port: %i\n", port);
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
    default: _fp_abort("Invalid port: %i\n", port);
  }
}

static inline uint32_t gpi_read_0() { return read_csr(CSR_UARCH0); }
static inline uint32_t gpi_read_1() { return read_csr(CSR_UARCH1); }
static inline uint32_t gpi_read_2() { return read_csr(CSR_UARCH2); }
static inline uint32_t gpi_read_3() { return read_csr(CSR_UARCH3); }

#endif
