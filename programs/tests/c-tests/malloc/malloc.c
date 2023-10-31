#include <stdlib.h>
#include <stdint.h>
#include <flexpret.h>

#define A_INIT 100
#define B_INIT 200
#define C_INIT 300

int main() {

    uint32_t* a = malloc(sizeof(uint32_t));
    uint32_t* b = malloc(sizeof(uint32_t));
    uint32_t* c = malloc(sizeof(uint32_t));
    uint32_t* d = malloc(sizeof(uint32_t));

    fp_assert(a && b && c && d, "Variable malloc failed");

    *a = A_INIT;
    *b = B_INIT;
    *c = C_INIT;
    *d = *a + *b + *c;

    fp_assert(*a == A_INIT, "Incorrect value for a");
    fp_assert(*b == B_INIT, "Incorrect value for b");
    fp_assert(*c == C_INIT, "Incorrect value for c");
    fp_assert(*d == (A_INIT + B_INIT + C_INIT), "Incorrect value for d");

    printf("a has address %p with value %i\n", a, *a);
    printf("b has address %p with value %i\n", b, *b);
    printf("c has address %p with value %i\n", c, *c);
    printf("d has address %p with value %i\n", d, *d);

    free(a);
    free(b);
    free(c);
    free(d);

    return 0;
}
