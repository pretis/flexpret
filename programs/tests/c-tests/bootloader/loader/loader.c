#include <stdbool.h>

#include <flexpret.h>

#define SYNC_ID_LEN 2
#define LEN_FIELD_LEN 2

// Warning: Do not use this macro, as it will change the size of the bootloader
//          between the 1st and 2nd compilation.
#ifndef APP_LOCATION
#define APP_LOCATION 0x1000
#endif // APP_LOCATION

#ifndef NDEBUG
#define DBG_PRINT(x) do { _fp_print(x); } while(0)
#else
#define DBG_PRINT(x) do {  } while(0)
#endif // NDEBUG

static void (*application)(void) = (void (*)())(APP_LOCATION);
int bootloader(void);

typedef enum {
    RECV_SYNC_ID,
    RECV_LEN,
    RECV_DATA,
    RECV_END_SYNC,
    FAULT
} app_recv_states_t;

void set_ledmask(const uint8_t byte)
{
    gpo_write_0((byte >> 0) & 0b11);
    gpo_write_1((byte >> 2) & 0b11);
    gpo_write_2((byte >> 4) & 0b11);
    gpo_write_3((byte >> 6) & 0b11);
}

// Global flag indicating that bootloading is done
// hart0 will set it to true. Other harts wait on it
static bool boot_done = false;

void main(void) {
    if ((gpi_read_0() & 0b1) == 0b1) {
        set_ledmask(0xFF);
        bootloader();
        set_ledmask(0x00);
    }

    // Jump to start.S
    application();
}

int bootloader(void) {
    unsigned char sync_id[SYNC_ID_LEN] = {0xC0, 0xDE};
    app_recv_states_t app_recv_state = RECV_SYNC_ID;
    unsigned int idx=0;
    unsigned int byte_idx=0;
    unsigned int *app_ptr = (unsigned int *) application;
    unsigned char recv_buffer[2];
    unsigned char recv;
    unsigned int len;
    unsigned int instr;

    while (1) {

// Useful if emulating and you want to see the progress
#ifdef __EMULATOR__
        uint32_t nbytes_written = (int)app_ptr - (int)application;
        if ((nbytes_written % 100) == 0) {
            fp_print_int(nbytes_written);
        }
#endif // __EMULATOR__
#ifdef __FPGA__
        uint32_t nbytes_written = (int)app_ptr - (int)application;
        if ((nbytes_written % 1000) == 0) {
            set_ledmask(nbytes_written / 1000);
        }
#endif // __FPGA__

        switch (app_recv_state) {

            case RECV_SYNC_ID: {
                DBG_PRINT(1);
                gpo_set(0, 2);
                recv=uart_receive();
                DBG_PRINT(recv);
                recv_buffer[1] = recv_buffer[0];
                recv_buffer[0] = recv;

                if (recv_buffer[0] == sync_id[0] && recv_buffer[1] == sync_id[1]) {
                    app_recv_state = RECV_LEN;
                    idx=0;
                    byte_idx=3;
                    instr = 0;
                    gpo_clear(0, 2);
                }
                break;
            }

            case RECV_LEN: {
                DBG_PRINT(2);
                gpo_set(0, 2);
                recv=uart_receive();
                DBG_PRINT(recv);
                recv_buffer[idx++] = recv;
                if (idx == LEN_FIELD_LEN) {
                    len = recv_buffer[1] << 8 | recv_buffer[0];        
                    app_recv_state = RECV_DATA;
                    idx = 0;
                    gpo_clear(0, 2);
                }
                break;
            }

            case RECV_DATA: {
                gpo_set(0, 4);
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
                    gpo_clear(0, 4);
                    app_recv_state = RECV_END_SYNC;
                    idx=0;
                }
                break;
            }

            case RECV_END_SYNC: {
                DBG_PRINT(4);
                gpo_set(0, 8);
                recv = uart_receive();
                recv_buffer[1] = recv_buffer[0];
                recv_buffer[0] = recv;
                DBG_PRINT(recv);
                if (++idx == SYNC_ID_LEN) {
                    if (recv_buffer[0] == sync_id[0] && recv_buffer[1] == sync_id[1]) {
                        // Sucessfully received the program
                        gpo_clear(0, 8);
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
}
