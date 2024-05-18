#include <flexpret/io.h>
#include <flexpret/csrs.h>
#include <flexpret/uart.h>
#include <stdlib.h> // itoa
#include <string.h> // strlen

void write_tohost_tid(uint32_t tid, uint32_t val) {
    switch(tid) {
        case 0: write_csr(CSR_TOHOST(0), val); break;
        case 1: write_csr(CSR_TOHOST(1), val); break;
        case 2: write_csr(CSR_TOHOST(2), val); break;
        case 3: write_csr(CSR_TOHOST(3), val); break;
        case 4: write_csr(CSR_TOHOST(4), val); break;
        case 5: write_csr(CSR_TOHOST(5), val); break;
        case 6: write_csr(CSR_TOHOST(6), val); break;
        case 7: write_csr(CSR_TOHOST(7), val); break;
        default: _fp_abort("Invalid thread id: %i\n", (int)tid);
    }
}

void write_tohost(uint32_t val) {
    int tid = read_hartid();
    write_tohost_tid(tid, val);
}

void fp_print_int(uint32_t val) {
#ifdef __EMULATOR__
    write_tohost(CSR_TOHOST_PRINT_INT);
    write_tohost(val);
#endif // __EMULATOR__
#ifdef __FPGA__
    // Max uint32_t is 4,294,967,295 -> 10 digits + \0
    char num[11];
    itoa(val, num, 10);
    for (size_t i = 0; i < strlen(num); i++) {
        uart_send(num[i]);
    }
#endif // __FPGA__
}

void fp_print_string(char *str) {
    do {
        uart_send((uint8_t) *str);
    } while (*str++ != '\0');
}

void gpo_write(uint32_t port, uint32_t val) {
    switch(port) {
        case 0: write_csr(CSR_UARCH4, val); break;
        case 1: write_csr(CSR_UARCH5, val); break;
        case 2: write_csr(CSR_UARCH6, val); break;
        case 3: write_csr(CSR_UARCH7, val); break;
        default: _fp_abort("Invalid port: %i\n", (int)port);
    }
}

void gpo_write_0(uint32_t val) { write_csr(CSR_UARCH4, val); }
void gpo_write_1(uint32_t val) { write_csr(CSR_UARCH5, val); }
void gpo_write_2(uint32_t val) { write_csr(CSR_UARCH6, val); }
void gpo_write_3(uint32_t val) { write_csr(CSR_UARCH7, val); }

void gpo_set_ledmask(const uint8_t byte) {
    gpo_write_0((byte >> 0) & 0b11);
    gpo_write_1((byte >> 2) & 0b11);
    gpo_write_2((byte >> 4) & 0b11);
    //gpo_write_3((byte >> 6) & 0b11);
}

void gpo_set(uint32_t port, uint32_t mask) {
    switch(port) {
        case 0: set_csr(CSR_UARCH4, mask); break;
        case 1: set_csr(CSR_UARCH5, mask); break;
        case 2: set_csr(CSR_UARCH6, mask); break;
        case 3: set_csr(CSR_UARCH7, mask); break;
        default: _fp_abort("Invalid port: %i\n", (int)port);
    }
}

void gpo_set_0(uint32_t mask) { set_csr(CSR_UARCH4, mask); }
void gpo_set_1(uint32_t mask) { set_csr(CSR_UARCH5, mask); }
void gpo_set_2(uint32_t mask) { set_csr(CSR_UARCH6, mask); }
void gpo_set_3(uint32_t mask) { set_csr(CSR_UARCH7, mask); }

void gpo_clear(uint32_t port, uint32_t mask) {
    switch(port) {
        case 0: clear_csr(CSR_UARCH4, mask); break;
        case 1: clear_csr(CSR_UARCH5, mask); break;
        case 2: clear_csr(CSR_UARCH6, mask); break;
        case 3: clear_csr(CSR_UARCH7, mask); break;
        default: _fp_abort("Invalid port: %i\n", (int)port);
    }
}

void gpo_clear_0(uint32_t mask) { clear_csr(CSR_UARCH4, mask); }
void gpo_clear_1(uint32_t mask) { clear_csr(CSR_UARCH5, mask); }
void gpo_clear_2(uint32_t mask) { clear_csr(CSR_UARCH6, mask); }
void gpo_clear_3(uint32_t mask) { clear_csr(CSR_UARCH7, mask); }

uint32_t gpo_read(uint32_t port) {
    switch(port) {
        case 0: return read_csr(CSR_UARCH4); break;
        case 1: return read_csr(CSR_UARCH5); break;
        case 2: return read_csr(CSR_UARCH6); break;
        case 3: return read_csr(CSR_UARCH7); break;
        default: _fp_abort("Invalid port: %i\n", (int)port);
    }
    return 0;
}

uint32_t gpo_read_0(void) { return read_csr(CSR_UARCH4); }
uint32_t gpo_read_1(void) { return read_csr(CSR_UARCH5); }
uint32_t gpo_read_2(void) { return read_csr(CSR_UARCH6); }
uint32_t gpo_read_3(void) { return read_csr(CSR_UARCH7); }

uint32_t gpi_read(uint32_t port) {
    switch(port) {
        case 0: return read_csr(CSR_UARCH0); break;
        case 1: return read_csr(CSR_UARCH1); break;
        case 2: return read_csr(CSR_UARCH2); break;
        case 3: return read_csr(CSR_UARCH3); break;
        default: _fp_abort("Invalid port: %i\n", (int)port);
    }
    return 0;
}

uint32_t gpi_read_0(void) { return read_csr(CSR_UARCH0); }
uint32_t gpi_read_1(void) { return read_csr(CSR_UARCH1); }
uint32_t gpi_read_2(void) { return read_csr(CSR_UARCH2); }
uint32_t gpi_read_3(void) { return read_csr(CSR_UARCH3); }
