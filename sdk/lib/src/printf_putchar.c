/**
 * @file printf_putchar.c
 * @author Magnus Mæhlum (magnusmaehlum@outlook.com)
 * 
 * The ../printf submodule implements printf(), but the function calls putchar_()
 * which needs to be defined by the user - as per the submodule's documentation.
 * 
 * This code implements the putchar_() function which either calls
 * _write_emulation() or _write_fpga() based on the __EMULATOR__ and
 * __FPGA__ defines.
 * 
 */

#include <stdint.h>
#include <errno.h>
#include <stdbool.h>
#include <string.h>

#include <flexpret/flexpret.h>
#include <flexpret/uart.h>

void _write_emulation(int fd, char character) {
    static bool first_character[FP_THREADS] = THREAD_ARRAY_INITIALIZER(true);
    
    // Use these variables to buffer up four characters at a time and send them
    // together. Keep one for each thread to make it thread-safe.
    static uint32_t word[FP_THREADS] = THREAD_ARRAY_INITIALIZER(0);
    static int word_idx[FP_THREADS] = THREAD_ARRAY_INITIALIZER(0);

    int tid = read_hartid();

    if (first_character[tid]) {
        // Write the additional information first, which is part of the defined
        // protocol between the CPU and emulator
        write_tohost_tid(tid, CSR_TOHOST_PRINTF);
        write_tohost_tid(tid, fd);
        first_character[tid] = false;
    }

    // Buffer up the character in the word
    word[tid] |= (character << (8 * word_idx[tid]));
    
    if (word_idx[tid] == 3) {
        // Write the word
        write_tohost_tid(tid, CSR_TOHOST_PRINTF);
        write_tohost_tid(tid, word[tid]);
        word_idx[tid] = 0;
        word[tid] = 0;
    } else {
        word_idx[tid]++;
    }

    // Last character
    if (character == '\0') {
        // If the word index is zero, then the word has already been written
        // and we do not need to do anything
        if (word_idx[tid] != 0) {
            // Otherwise we need to send the word
            write_tohost_tid(tid, CSR_TOHOST_PRINTF);
            write_tohost_tid(tid, word[tid]);
        }

        // Reset for next printf
        first_character[tid] = true;
        word_idx[tid] = 0;
        word[tid] = 0;
    }
}

void _write_fpga(int fd, char character) {
    UNUSED(fd);
    uart_send(character);
}

void putchar_(char character) {
#ifdef __EMULATOR__
    _write_emulation(1, character); // TODO: Use real file descriptors?
#endif // __EMULATOR__
#ifdef __FPGA__
    _write_fpga(1, character);
#endif // __FPGA__
}
