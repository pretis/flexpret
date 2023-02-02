#include <stdint.h>
#include <stdbool.h>

#ifndef NUM_THREADS
#define NUM_THREADS 1
#endif

/**
 * Constants for FlexPRET scheduling (i.e. slots and tmodes)
 * These values must match those in constants.scala.
 */

// Maximum slots
#define SLOTS_SIZE  8

// Helper macros for making
// thread_create() and thread_map()
// more readable.
#define HRTT        true
#define SRTT        false

// Possible values for a slot
typedef enum slot_t {
    SLOT_T0=0,
    SLOT_T1, SLOT_T2, SLOT_T3, SLOT_T4,
    SLOT_T5, SLOT_T6, SLOT_T7,
    SLOT_S=14,
    SLOT_D=15
} slot_t;

// Possible values for a thread mode
typedef enum tmode_t {
    TMODE_HA=0,   // HRTT Active
    TMODE_HZ,     // HRTT Sleeping
    TMODE_SA,     // SRTT Active
    TMODE_SZ      // SRTT Sleeping
} tmode_t;

/* FlexPRET's hardware thread scheduling APIs */

int slot_set(slot_t slots[], uint32_t length);
int slot_set_hrtt(uint32_t slot, uint32_t hartid);
int slot_set_srtt(uint32_t slot);
int slot_disable(uint32_t slot);
tmode_t tmode_get(uint32_t hartid);
int tmode_set(uint32_t hartid, tmode_t val);
int tmode_active(uint32_t hartid);
int tmode_sleep(uint32_t hartid);


/* Pthreads-like threading library APIs */

typedef uint32_t thread_t;

int thread_create(
    bool is_hrtt,   // HRTT = true, SRTT = false
    thread_t *restrict hartid,
    void *(*start_routine)(void *),
    void *restrict arg
);
int thread_map(
    bool is_hrtt,   // HRTT = true, SRTT = false
    thread_t *restrict hartid,
    void *(*start_routine)(void *),
    void *restrict arg
);
int thread_join(thread_t thread, void **retval);
void thread_exit(void *retval);
int thread_cancel(thread_t thread);
void thread_testcancel();
void worker_main();