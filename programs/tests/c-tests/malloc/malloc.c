#include <stdlib.h>
#include <stdint.h>
#include <signal.h>
#include <flexpret.h>

#define A_INIT 100
#define B_INIT 200
#define C_INIT 300

#define NELEMENTS_ARRAY (10)

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

    uint32_t *array = malloc(sizeof(uint32_t) * NELEMENTS_ARRAY);
    fp_assert(array, "Could not allocate %i bytes", sizeof(uint32_t) * NELEMENTS_ARRAY);
    free(array);

    /**
     * newlib's signal() function uses the _malloc_r() function, which does not work
     * with the custom tinyalloc module used in this project. The _malloc_r() 
     * function does not have knowledge of the tinyalloc module, meaning it will
     * overwrite some internal state.
     * 
     * The solution to this issue is to overwrite the _malloc_r() function with a
     * custom (tinyalloc-style) implementation. newlib does not natively support
     * this, so the _malloc_r() symbol needs to be weakened so we can provide our
     * own implementation.
     * 
     * This is done with the weaken target in the make system.
     * The custom implementation is found in lib/syscalls/heap.c
     * 
     * Try to comment out the custom implementation - then the linker will instead
     * use the default _malloc_r() and the test will fail since it overwrites 
     * tinyalloc's state.
     * 
     */
    signal(SIGINT, exit);
    uint32_t *new = malloc(sizeof(uint32_t) * NELEMENTS_ARRAY);
    fp_assert(new, "Could not allocate %i bytes", sizeof(uint32_t) * NELEMENTS_ARRAY);
    free(new);

    return 0;
}
