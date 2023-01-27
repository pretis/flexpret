#include <stdint.h>

#ifndef NUM_THREADS
#define NUM_THREADS 1
#endif

/**
 * FlexPRET related constants (i.e. for slots and tmodes)
 * These values must match those in constants.scala.
 */

// Special values for a slot.
#define SLOT_S      14
#define SLOT_D      15

#define SLOTS_SIZE  8

// Possible values for a tmode.
#define TMODE_HA    0
#define TMODE_HZ    1
#define TMODE_SA    2
#define TMODE_SZ    3

/* FlexPRET's hardware thread scheduling APIs */

int set_slot_hrtt(uint32_t slot, uint32_t hartid);
int set_slot_srtt(uint32_t slot);
int set_slot_disable(uint32_t slot);
int set_tmode(uint32_t hartid, uint32_t val);


/* Pthreads-like threading library APIs */

typedef uint32_t thread_t;

int thread_create(
    thread_t *restrict hartid,
    void *(*start_routine)(void *),
    void *restrict arg
);
int thread_map(
    thread_t *restrict hartid,
    void *(*start_routine)(void *),
    void *restrict arg
);
int thread_join(thread_t thread, void **retval);
void thread_exit(void *retval);
int thread_cancel(thread_t thread);
void thread_testcancel();
void worker_main();