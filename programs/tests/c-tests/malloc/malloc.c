#include <stdlib.h>
#include <stdint.h>
#include <flexpret_io.h>

int main() {

    uint32_t* a = malloc(sizeof(uint32_t));
    uint32_t* b = malloc(sizeof(uint32_t));
    uint32_t* c = malloc(sizeof(uint32_t));
    uint32_t* d = malloc(sizeof(uint32_t));

    *a = 100;
    *b = 200;
    *c = 300;
    *d = *a + *b + *c;

    _fp_print(*a);
    _fp_print(*b);
    _fp_print(*c);
    _fp_print(*d);

    free(a);
    free(b);
    free(c);
    free(d);

    return 0;
}
