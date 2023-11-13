/**
 * @author Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 * @brief A wrapper module to expose standard heap functions (malloc, free, etc.),
 * but with some wrapper code around for debugging purposes.
 * 
 */

#include <stdint.h>
#include <flexpret.h>
#include <reent.h>

#include "../tinyalloc/tinyalloc.h"

#define CHECK_PTR_WITHIN_HEAP_OR_NULL(ptr, lower, upper) \
    (lower <= ptr && ptr <= upper) || (ptr == NULL)

#define SANITY_CHECK(addr) do { \
    fp_assert(CHECK_PTR_WITHIN_HEAP_OR_NULL((uint32_t *) (addr), &__sheap, &__eheap), \
        "sanity check failed: address outside of heap space: addr: %p, heap start: %p, end heap: %p\n", \
        addr, &__sheap, &__eheap); \
} while(0)

// Linker variables
extern uint32_t __sheap;
extern uint32_t __eheap;

/**
 * Allocate a requested memory and return a pointer to it.
 */
void *malloc(size_t size) {
    void *ptr = ta_alloc(size);
    SANITY_CHECK(ptr);
    return ptr;
}

void *_malloc_r(struct _reent *r, size_t size) {
    return malloc(size);
}

/**
 * Allocate a requested memory, initial the memory to 0,
 * and return a pointer to it.
 */
void *calloc(size_t nitems, size_t size) {
    void *ptr = ta_calloc(nitems, size);
    SANITY_CHECK(ptr);
    return ptr;
}

void *_calloc_r(struct _reent *r, size_t nitems, size_t size) {
    return calloc(nitems, size);
}

/**
 * resize the memory block pointed to by ptr
 * that was previously allocated with a call
 * to malloc or calloc.
 */
void *realloc(void *ptr, size_t size) {
    SANITY_CHECK(ptr);
    void *ret = ta_realloc(ptr, size);
    SANITY_CHECK(ret);
    return ret;
}

void *_realloc_r(struct _reent *r, void *ptr, size_t size) {
    return realloc(ptr, size);
}

/**
 * Deallocate the memory previously allocated by a call to calloc, malloc, or realloc.
 */
void free(void *ptr) {
    SANITY_CHECK(ptr);
    ta_free(ptr);
}

