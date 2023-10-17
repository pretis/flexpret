#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>

#include "common.h"

#define HIGH (1)
#define LOW  (0)

static struct PinEvent interrupt[2] = {
    { .in_n_cycles = 10000, .high_low = HIGH },
    { .in_n_cycles = 0, .high_low = LOW },
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
