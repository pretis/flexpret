

// Client side C/C++ program to demonstrate Socket 
// programming 
#include <arpa/inet.h> 
#include <stdio.h> 
#include <string.h> 
#include <sys/socket.h> 
#include <unistd.h> 
#include <stdbool.h>

#define PORT 8080 

struct PinEvent {
    uint32_t in_n_cycles;
    bool high_low;
};

#define HIGH (1)
#define LOW  (0)

static struct PinEvent events[2] = {
    { .in_n_cycles = 10000, .high_low = HIGH },
    { .in_n_cycles = 0, .high_low = LOW },
};

int main(int argc, char const* argv[]) 
{ 
    int status, valread, client_fd; 
    struct sockaddr_in serv_addr; 
    if ((client_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) { 
        printf("\n Socket creation error \n"); 
        return -1; 
    } 
  
    serv_addr.sin_family = AF_INET; 
    serv_addr.sin_port = htons(PORT); 
  
    // Convert IPv4 and IPv6 addresses from text to binary 
    // form 
    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) 
        <= 0) { 
        printf( 
            "\nInvalid address/ Address not supported \n"); 
        return -1; 
    } 
  
    if ((status 
         = connect(client_fd, (struct sockaddr*)&serv_addr, 
                   sizeof(serv_addr))) 
        < 0) { 
        printf("\nConnection Failed \n"); 
        return -1; 
    }

    getchar();

    send(client_fd, events, sizeof(events), 0);
  
    // closing the connected socket 
    close(client_fd); 
    return 0; 
}
