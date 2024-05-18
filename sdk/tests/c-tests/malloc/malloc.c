#include <stdlib.h>
#include <stdint.h>
#include <signal.h>
#include <errno.h>
#include <string.h>

#include <flexpret/flexpret.h>

#define A_INIT 100
#define B_INIT 200
#define C_INIT 300

#define NELEMENTS_ARRAY (10)

extern char __sheap;
extern char __eheap;

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

    printf("a has address %p with value %i\n", a, (int) *a);
    printf("b has address %p with value %i\n", b, (int) *b);
    printf("c has address %p with value %i\n", c, (int) *c);
    printf("d has address %p with value %i\n", d, (int) *d);

    free(a);
    free(b);
    free(c);
    free(d);

    uint32_t *array = malloc(sizeof(uint32_t) * NELEMENTS_ARRAY);
    fp_assert(array, "Could not allocate %i bytes", sizeof(uint32_t) * NELEMENTS_ARRAY);
    free(array);

    // signal uses internal malloc functionality; check that it does not mess
    // up anything
    signal(SIGINT, exit);
    uint32_t *new = malloc(sizeof(uint32_t) * NELEMENTS_ARRAY);
    fp_assert(new, "Could not allocate %i bytes", sizeof(uint32_t) * NELEMENTS_ARRAY);
    free(new);

    // Check that an extremely large malloc does not work
    char *massive = malloc(0x30000000);
    fp_assert(massive == NULL, "Massive malloc worked\n");
    fp_assert(errno == ENOMEM, "Errno not as expected, was: %s\n", strerror(errno));

    printf("Could not allocate massive array: %s (as expected)\n", strerror(errno));

    /**
     * Malloc the entire heap and check that it is no longer possible to malloc
     * anything. This is the last test, since we have no way of getting the heap
     * back :)
     * 
     * To malloc the entire heap, it needs to be done in diminishing blocks, since
     * the heap is likely fragmented from earlier use. It will not work to just
     * malloc the entire heap in one go - that will leave some fragments.
     * 
     */
    uint32_t block_size = 0x10000;
    while (block_size > 1) {
        if (malloc(block_size) == NULL) {
            block_size /= 2;
        }
    }

    fp_assert(malloc(1) == NULL, "Could malloc when not expected\n");
    fp_assert(errno == ENOMEM, "Errno not set as expected\n");

    printf("Sucessfully malloc'ed entire heap\n");

    return 0;
}
