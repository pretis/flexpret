#include <stdbool.h>
#include <flexpret/flexpret.h>

#define SYNC_ID_LEN 2
#define LEN_FIELD_LEN 4

#include <location.h>

/**
 * The app will be placed right after the bootloader. However, the size of the
 * bootloader depends on the bootloader itself. Therefore, the bootloader is
 * compiled once to determine its size. The size is then passed to it through
 * this variable. 
 * 
 * Usage of this macro should be avoided, because when its value changes between
 * the 1st and 2nd compilation, it may trigger some unexpected effects.
 * 
 * E.g., if it is used to initialize a variable, the variable will
 * be placed in .bss if the macro is 0 but .data otherwise.
 * It can also cause some unexpected optimization.
 * 
 */
#ifndef APP_LOCATION
#define APP_LOCATION 0x1000
#endif // APP_LOCATION

#if 0
#define DBG_PRINT(x) do { fp_print_int(x); } while(0)
#else
#define DBG_PRINT(x) do {  } while(0)
#endif // NDEBUG

void (*application)(void) = (void (*)(void))(APP_LOCATION);
int bootloader(void);

typedef enum {
    RECV_SYNC_ID,
    RECV_LEN,
    RECV_DATA,
    RECV_END_SYNC,
    FAULT
} app_recv_states_t;

// Global flag indicating that bootloading is done
// hart0 will set it to true. Other harts wait on it
bool boot_done = false;

int main(void) {
    if ((gpi_read_0() & 0b1) == 0b1) {
        gpo_set_ledmask(0xFF);
        bootloader();
        gpo_set_ledmask(0x00);
    }

    boot_done = true;

    // Jump to start.S
    application();
    return 0;
}

int bootloader(void) {
    unsigned char sync_id[SYNC_ID_LEN] = {0xC0, 0xDE};
    app_recv_states_t app_recv_state = RECV_SYNC_ID;
    unsigned int idx=0;
    unsigned int byte_idx=0;
    unsigned int *app_ptr = (unsigned int *) application;
    unsigned char recv_buffer[4];
    unsigned char recv;
    unsigned int len = 0;
    unsigned int instr = 0;

    // Disable instruction memory protection
    write_csr(CSR_IMEM_PROT, 0x88888888);

    while (1) {
#if 1
        // LEDs will blink when uploading software
        uint32_t nbytes_written = (int)app_ptr - (int)application;
        if ((nbytes_written % 1000) == 0) {
            gpo_set_ledmask(nbytes_written / 1000);
        }
#else
        // Useful if emulating and you want to see the progress
        uint32_t nbytes_written = (int)app_ptr - (int)application;
        if ((nbytes_written % 100) == 0) {
            fp_print_int(nbytes_written);
        }
#endif


        switch (app_recv_state) {

            case RECV_SYNC_ID: {
                
                DBG_PRINT(1);
                gpo_set_ledmask(0x01);
                recv=uart_receive();
                DBG_PRINT(recv);
                recv_buffer[1] = recv_buffer[0];
                recv_buffer[0] = recv;

                if (recv_buffer[0] == sync_id[0] && recv_buffer[1] == sync_id[1]) {
                    app_recv_state = RECV_LEN;
                    idx=0;
                    byte_idx=3;
                    instr = 0;
                }
                break;
            }

            case RECV_LEN: {
                DBG_PRINT(2);
                recv=uart_receive();
                DBG_PRINT(recv);
                recv_buffer[idx++] = recv;
                if (idx == LEN_FIELD_LEN) {
                    len = (recv_buffer[3] << 24)
                        | (recv_buffer[2] << 16)
                        | (recv_buffer[1] << 8) 
                        | (recv_buffer[0] << 0);
                    app_recv_state = RECV_DATA;
                    idx = 0;
                }
                break;
            }

            case RECV_DATA: {
                recv = uart_receive();
                instr = instr | (((unsigned int) recv) << 8*byte_idx);
                if (byte_idx-- == 0) {
                    DBG_PRINT(3);
                    DBG_PRINT(app_ptr);
                    DBG_PRINT(instr);
                    *(app_ptr++) = instr;
                    instr = 0;
                    byte_idx=3;
                }

                if (++idx == len) {
                    app_recv_state = RECV_END_SYNC;
                    idx=0;
                }
                break;
            }

            case RECV_END_SYNC: {
                DBG_PRINT(4);
                recv = uart_receive();
                recv_buffer[1] = recv_buffer[0];
                recv_buffer[0] = recv;
                DBG_PRINT(recv);
                if (++idx == SYNC_ID_LEN) {
                    if (recv_buffer[0] == sync_id[0] && recv_buffer[1] == sync_id[1]) {
                        // Sucessfully received the program
                        return 0;
                    }
                    else {
                        app_recv_state = FAULT;
                    }
                }
                break;
            }

            case FAULT: {
                return -1;
            }

            default: {
                app_recv_state = FAULT;
            }
        }
    }

    // Enable memory protection on entire instruction memory
    write_csr(CSR_IMEM_PROT, 0xCCCCCCCC);
}
