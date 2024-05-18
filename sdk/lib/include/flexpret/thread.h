#ifndef FLEXPRET_THREAD_H
#define FLEXPRET_THREAD_H

#include <stdint.h>
#include <stdbool.h>

#ifndef FP_THREADS
#define FP_THREADS 1
#endif

#ifndef THREAD_STACKSIZE
#define THREAD_STACKSIZE_BITS 11
#define THREAD_STACKSIZE (1 << THREAD_STACKSIZE_BITS)
#endif

/**
 * Constants for FlexPRET scheduling (i.e. slots and tmodes)
 * These values must match those in constants.scala.
 */

// Maximum slots
#define SLOTS_SIZE  8

// Helper macros for making
// fp_thread_create() and fp_thread_map()
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

/**
 * This struct contains a context; i.e., the values of the registers before a
 * context switch occurred. A context switch typically occurs due to an interrupt.
 * 
 * The struct is not in direct use anywhere, but is kept for reference. An
 * implementation of a context switch can be found in ../ctx_switch.S
 * 
 */
typedef struct thread_ctx_t {
    uint32_t regs[32];
} thread_ctx_t;

typedef uint32_t fp_thread_t;

int fp_thread_create(
    bool is_hrtt,   // HRTT = true, SRTT = false
    fp_thread_t *restrict hartid,
    void *(*start_routine)(void *),
    void *restrict arg
);
int fp_thread_map(
    bool is_hrtt,   // HRTT = true, SRTT = false
    fp_thread_t *restrict hartid,
    void *(*start_routine)(void *),
    void *restrict arg
);
int fp_thread_join(fp_thread_t thread, void **retval);
void fp_thread_exit(void *retval);
int fp_thread_cancel(fp_thread_t thread);
void fp_thread_testcancel();
void worker_main();

#endif