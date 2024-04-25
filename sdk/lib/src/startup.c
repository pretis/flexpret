/**
 * FlexPRET's startup code in C
 * 
 * Authors:
 * - Shaokai Lin
 * - Samuel Berkun
 */

#include <unistd.h>      // Declares _exit() with definition in syscalls.c.
#include <flexpret/flexpret.h>


/* Linker */
extern uint32_t __stext;
extern uint32_t __etext;
extern uint32_t __sdata;
extern uint32_t __edata;
extern uint32_t __sbss;
extern uint32_t __ebss;

/**
 * The heap  starts after .text, .data, and .bss (see linker script).
 * The stack starts at the very end of RAM.
 * 
 * The heap grows downwards while the stack grows upwards.
 * Therefore, the __eheap and __estack variables should be equal.
 * 
 */
extern uint32_t __sheap;
extern uint32_t __eheap;
extern uint32_t __estack;
extern uint32_t __sstack;


/* Threading */
static volatile bool     __ready__;
extern volatile bool     exit_requested[FP_THREADS];
extern volatile uint32_t num_threads_busy;
extern volatile uint32_t num_threads_exited;

//prototype of main
int main(void);
void Reset_Handler(void) __attribute__((weak));

void syscalls_init(void);

static inline bool check_bounds_inclusive(const void *val, const void *lower, const void *upper) {
    return lower <= val && val <= upper;
}

/**
 * Initialize initialized global variables, set uninitialized global variables
 * to zero, configure tinyalloc, and jump to main.
 */
fp_lock_t _lock = FP_LOCK_INITIALIZER;
void Reset_Handler() {
    // Get hartid
    uint32_t hartid = read_hartid();

    // Only thread 0 performs the setup,
    // the other threads busy wait until ready.
    if (hartid == 0) {
        // Copy .data section into the RAM
        uint32_t size   = &__edata - &__sdata;
        uint32_t *pDst  = (uint32_t*)&__sdata; // RAM
        uint32_t *pSrc  = (uint32_t*)&__etext; // ROM

        for (uint32_t i = 0; i < size; i++) {
            pDst[i] = pSrc[i];
        }

        // Init. the .bss section to zero in RAM
        size = (uint32_t)&__ebss - (uint32_t)&__sbss;
        pDst = (uint32_t*)&__sbss;
        for(uint32_t i = 0; i < size; i++) {
            pDst[i] = 0;
        }

#ifndef NDEBUG
        // Perform some sanity checks on the stack and heap pointers
        const uint32_t *stack_end_calculated = (uint32_t *)
            ((uint32_t) (&__sstack) - (FP_THREADS * FP_STACKSIZE));

        fp_assert(&__estack == stack_end_calculated, 
            "Stack not set up correctly: End of stack: %p, Calculated end of stack: %p\n",
            &__estack, stack_end_calculated);

        fp_assert(&__eheap == &__estack, 
            "Heap end and stack end are not equal: Heap end: %p, Stack end: %p\n",
            &__eheap, &__estack);
#endif // NDEBUG

        /**
         * Configure flexible scheduling
         * 
         * The default schedule (i.e. encoded in slots)
         * being set here allocates each hardware thread
         * a slot. For example,
         * if FlexPRET has four threads, then the slots
         * are [T0 T1 T2 T3 D D D D].
         * Here, during startup, they are
         * configured as HRTTs. After startup,
         * T1, T2, and T3 are put to sleep, and T1, T2,
         * and T3 are then used for SRTTs.
         * 
         * The user can set the thread modes when
         * fp_thread_create() or fp_thread_map() is called. 
         * 
         * If the user wants to change the schedule,
         * the user can call slot_set(), slot_set_hrtt(),
         * slot_set_srtt(), slot_disable(), and tmode_set().
         * But normally, the user does not need to
         * worry about them since a "one-slot-per-thread"
         * schedule seems sufficient for most applications.
         */
        // Signal all the other (currently HRTT) threads
        // to wake up and execute up to here,
        // by allocating the slots to them.
        slot_t slots[8];
        for (int i = 0; i < FP_THREADS; i++) {
            slots[i] = i;
        }
        // Disable slots with ID >= FP_THREADS,
        for (int j = FP_THREADS; j < SLOTS_SIZE; j++)
            slots[j] = SLOT_D;
        
        // Acquire lock and allow all threads to start execute as HRTTs
        fp_hwlock_acquire();
        for (int i = 0; i < FP_THREADS; i++) {
            tmode_set(i, TMODE_HA);
        }
        slot_set(slots, 8);
        fp_hwlock_release();

        // FIXME: Wait for a worker thread to signal
        // ready-to-sleep and put it to sleep.

        // Signal everything is ready.
        fp_hwlock_acquire();
        __ready__ = true;
        fp_hwlock_release();
    } else {
        // FIXME: Signal thread 0 to put
        // the worker thread to sleep.

        // Wait for thread 0 to finish setup.
        while (!__ready__);
    }

#ifndef NDEBUG
    // Check that each thread's stack pointer is within its own stack start/end
    // addresses
    register uint32_t *stack_pointer asm("sp");
    
    const uint32_t *stack_start = (uint32_t *)
        ((uint32_t) (&__sstack) - (hartid * FP_STACKSIZE));
    
    const uint32_t *stack_end   = (uint32_t *) 
        ((uint32_t) (stack_start) - FP_STACKSIZE);

    fp_assert(check_bounds_inclusive(stack_pointer, stack_end, stack_start),
        "Stack pointer incorrectly set: %p\n", stack_pointer);

    uint32_t hwconfighash = read_csr(CSR_CONFIGHASH);
    fp_assert(hwconfighash == FP_CONFIGHASH,
        "Hardware and software configuration mismatch (0x%x vs. 0x%x)\n",
        (unsigned int) hwconfighash, (unsigned int) FP_CONFIGHASH);
#endif // NDEBUG

    // Setup exception handling
    setup_exceptions();

    // Call main().
    int ret = 0;
    if (hartid == 0) {
        ret = main();
    } else {
        worker_main();
    }

    // Shutdown the program.
    if (hartid == 0) {
        /* Make sure all worker threads properly shutdown. */

        // Wait for all hardware worker threads
        // to finish their ongoing routines.
        while (num_threads_busy > 0);

        // Signal all threads besides T0 to exit.
        fp_hwlock_acquire();
        for (int i = 1; i < FP_THREADS; i++) {
            exit_requested[i] = true;
            // FIXME: If the thread is sleeping,
            // wake up the thread.
        }
        fp_hwlock_release();

        // Wait for all hardware worker threads to exit.
        while (num_threads_exited < FP_THREADS-1);

        // FIXME: Execute the main thread
        // clean up handlers here.

        // Exit the program.
        _exit(ret);
    } else {
        while (1);
    }
}
