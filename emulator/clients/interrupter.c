#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>

#include "common.h"

static struct PinEvent interrupt[2] = {
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = 10000, .high_low = HIGH },
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = 0,     .high_low = LOW  },
};

int main(int argc, char const* argv[]) 
{ 
    int client_fd = setup_socket();

    while (1) {
        getchar();
        send(client_fd, interrupt, sizeof(interrupt), 0);
    }
  
    close(client_fd); 
    return 0; 
}
