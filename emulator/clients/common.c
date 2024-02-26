#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdio.h>

#include "common.h"

int setup_socket(void) {
    int status, valread, client_fd;
    struct sockaddr_in serv_addr;
    if ((client_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("\nSocket creation error \n");
        return -1;
    }
  
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(CLIENT_PORT);
  
    // Convert IPv4 and IPv6 addresses from text to binary form 
    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0) {
        printf("\nInvalid address/ Address not supported \n");
        return -1;
    }
  
    if ((status = connect(client_fd, (struct sockaddr*)&serv_addr,
            sizeof(serv_addr))) < 0) {
        printf("Connection failed \n"); 
        return -1;
    }

    return client_fd;
}