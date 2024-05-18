#ifndef FLEXPRET_IO_H
#define FLEXPRET_IO_H

#include <stdint.h>
#include <flexpret/csrs.h>

#ifndef NDEBUG
#include <printf/printf.h>
#endif // NDEBUG

#define CSR_TOHOST_PRINTF    (0xffffffff)
#define CSR_TOHOST_PRINT_INT (0xbaaabaaa)
#define CSR_TOHOST_FINISH    (0xdeaddead)
#define CSR_TOHOST_ABORT     (0xdeadbeef)

#define PRINTF_COLOR_RED   "\x1B[31m"
#define PRINTF_COLOR_GREEN "\x1B[32m"
#define PRINTF_COLOR_NONE  "\x1B[0m"

#if defined(HAVE_PRINTF) && !defined(NDEBUG)

    #define _fp_abort(fmt, ...) do { \
        printf("%s: %s: %i: " PRINTF_COLOR_RED "Abort:" PRINTF_COLOR_NONE, __FILE__, __func__, __LINE__); \
        printf(fmt, ##__VA_ARGS__); \
        gpo_set_ledmask(__LINE__ % 255); \
        write_tohost(CSR_TOHOST_ABORT); \
    } while(0)
    
    #define _fp_finish() do { \
        printf("%s: %i: " PRINTF_COLOR_GREEN "Finish\n" PRINTF_COLOR_NONE, __FILE__, __LINE__); \
        gpo_set_ledmask((1 << 7)); \
        write_tohost(CSR_TOHOST_FINISH); \
    } while(0)

#else

    #define _fp_abort(fmt, ...) do { \
        gpo_set_ledmask(__LINE__ % 255); \
        write_tohost(CSR_TOHOST_ABORT); \
    } while (0)

    #define _fp_finish() do { \
        write_tohost(CSR_TOHOST_FINISH); \
    } while(0)

#endif // HAVE_PRINTF

/**
 * @brief Write a generic value to the tohost CSR
 * 
 * @param tid Thread ID
 */
void write_tohost_tid(uint32_t tid, uint32_t val);

/**
 * @brief Write a generic value to the tohost CSR, but fetch the thread ID automatically
 * 
 */
void write_tohost(uint32_t val);

/**
 * @brief Print just a single number to emulator
 * 
 * @param val The number to print. Note that the number cannot be CSR_TOHOST_PRINT_INT.
 */
void fp_print_int(uint32_t val);

void fp_print_string(char *str);

/**
 * @brief Write to general purpose output, if port width < 32, then upper bits ignored
 * 
 * @param port 
 * @param val 
 */
void gpo_write(uint32_t port, uint32_t val);

void gpo_write_0(uint32_t val);
void gpo_write_1(uint32_t val);
void gpo_write_2(uint32_t val);
void gpo_write_3(uint32_t val);

/**
 * @brief Set all the eight LEDs on the Zedboard FPGA to the byte
 * 
 * @param byte 
 * 
 * FIXME: Generalize to all FPGAs or remove
 */
void gpo_set_ledmask(const uint8_t byte);

/**
 * @brief Set pins of general purpose output - do not overwrite other values
 * 
 * @param port 
 * @param mask 
 */
void gpo_set(uint32_t port, uint32_t mask);

void gpo_set_0(uint32_t mask);
void gpo_set_1(uint32_t mask);
void gpo_set_2(uint32_t mask);
void gpo_set_3(uint32_t mask);

/**
 * @brief For each '1' bit in mask, set corresponding GPO bit to '0'
 * 
 * @param port 
 * @param mask 
 */
void gpo_clear(uint32_t port, uint32_t mask);

void gpo_clear_0(uint32_t mask);
void gpo_clear_1(uint32_t mask);
void gpo_clear_2(uint32_t mask);
void gpo_clear_3(uint32_t mask);

/**
 * @brief Read general purpose output pins
 * 
 * @param port 
 * @return uint32_t 
 */
uint32_t gpo_read(uint32_t port);

uint32_t gpo_read_0(void);
uint32_t gpo_read_1(void);
uint32_t gpo_read_2(void);
uint32_t gpo_read_3(void);

/**
 * @brief Read from general purpose input - if port width < 32, then upper bits are zero
 * 
 * @param port 
 * @return uint32_t 
 */
uint32_t gpi_read(uint32_t port);

uint32_t gpi_read_0(void);
uint32_t gpi_read_1(void);
uint32_t gpi_read_2(void);
uint32_t gpi_read_3(void);

#endif
