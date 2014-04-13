// Assembly macros.
//
#define PCR_STATUS cr0
#define PCR_EPC cr1
#define PCR_EVEC cr3
#define PCR_SHARED cr18
#define PCR_PRIV_L cr19
#define PCR_PRIV_H cr20
#define PCR_SCHEDULE cr22
#define PCR_TMODES cr23
#define PCR_TSUP cr24
#define PCR_INSTS cr25
#define PCR_CYCLES cr26
#define PCR_TID cr27
#define PCR_TOHOST cr30

// Function: All threads except tid=0 are in infinite loop.
// Affected: tmp1
#define START_SINGLE_THREAD(tmp1) \
        mfpcr tmp1, PCR_TID; \
inf0:   bne x0, tmp1, inf0;

// Function: Get time (lower 32ns)
// Output x2
#define GT_L \
        .word 0x1000005B;

// Function: Get time (upper 32ns)
// Output x3
#define GT_H \
        .word 0x180000DB;

// Function: Delay Until
// Input x3.x2
#define DU \
        .word 0x00C4015B;

#define IE_E \
        .word 0x00C401DB;

#define IE_D \
        .word 0x0000025B;

#define TS \
        .word 0x000002DB;


// Function: Reset counters.
#define RESET_COUNTERS \
        mtpcr x0, PCR_INSTS; 

// Function: Read instruction count.
// Output: count
#define READ_INST_COUNT(count) \
        mfpcr count, PCR_INSTS;

// Function: Read cycle count.
// Output: count
#define READ_CYCLE_COUNT(count) \
        mfpcr count, PCR_CYCLES;

// Function: Set scheduling frequency of tid=0 
// (Assumes other threads in infinite loop).
// Input: dem
//
// Notes: 
// First activates as many slots as dem ((1<<dem)-1)
// Then set tid of slot to be slot index.
#define SET_SCHEDULING_FREQ(dem, tmp1, tmp2) \
        li tmp1, -1; \
        move tmp2, dem; \
1:  addi tmp2, tmp2, -1; \
        slli tmp1, tmp1, 4; \
        beq x0, tmp2, 2f; \
        ori tmp1, tmp1, 14; \
        j 1b; \
2:  mtpcr tmp1, PCR_SCHEDULE; \
        li tmp1, 0; \
        mtpcr tmp1, PCR_TMODES; \
        nop; \
        nop; \
        nop; \
        nop;

// Function: Read if thread scheduling is flexible.
// Output flex
#define READ_FLEX_THREADS(flex) \
        mfpcr flex, PCR_STATUS; \
        srli flex, flex, 31;

// Function: Read maximum number of threads.
// Output threads
#define READ_MAX_THREADS(threads) \
        mfpcr threads, PCR_STATUS; \
        srli threads, threads, 28; \
        andi threads, threads, 7; \
        addi threads, threads, 1;
    
// TOHOST interface for simulation.

// Function: Send scheduling frequency over tohost.
// Affected: tmp1
#define TOHOST_SCHEDULING_FREQ(freq, tmp1) \
        lui tmp1, 0x40000; \
        or tmp1, tmp1, freq; \
        mtpcr tmp1, cr30;

// Function: Send instruction count over tohost.
// Input: count
// Affected: tmp1
#define TOHOST_INST_COUNT(count, tmp1) \
        lui tmp1, 0x80000; \
        or tmp1, tmp1, count; \
        mtpcr tmp1, cr30;

// Function: Send cycle count over tohost.
// Input: count
// Affected: tmp1
#define TOHOST_CYCLE_COUNT(count, tmp1) \
        lui tmp1, 0xC0000; \
        or tmp1, tmp1, count; \
        mtpcr tmp1, cr30;

// Function: Send pass and spin.
// Affected: tmp1
#define TOHOST_PASS(tmp1) \
        li tmp1, 1; \
        mtpcr tmp1, cr30; \
inf1:   beq x0, x0, inf1;

// TODO: assumes word aligned.
#define STARTUP(f, sbss, ebss, stack, tmp1, tmp2) \
        la tmp1, sbss; \
        la tmp2, ebss; \
1:      bge tmp1, tmp2, 2f; \
        sw x0, 0(tmp1); \
        addi tmp1, tmp1, 4; \
        j 1b; \
2:      la sp, stack; \
        jal f; \
3:      j 3b;
        
// Set low and high address for thread data.
// Shift out page bits (TODO: change src to not require this)
// Set thread ID being set
#define MEM_ISO(thread, low, high, tmp1, tmp2) \
        lui tmp1, (thread << 17); \
        la tmp2, low; \
        srli tmp2, tmp2, 10; \
        or tmp2, tmp1, tmp2; \
        mtpcr tmp2, PCR_PRIV_L; \
        la tmp2, high; \
        srli tmp2, tmp2, 10; \
        or tmp2, tmp1, tmp2; \
        mtpcr tmp2, PCR_PRIV_H; \

#define tohost_id(thread,op) ((1 << 30) | (thread << 27) | (op))
// Number must be under ~1e9 (2^30)
#define tohost_time(val) ((2 << 30) | (val))
        
#define mtpcr(pcr,val)				\
({						\
	register unsigned int __tmp;		\
	__asm__ __volatile__ (			\
		"mtpcr %0, %1, cr%2"		\
		: "=r" (__tmp)			\
		: "r" (val), "i" (pcr));	\
	__tmp;					\
})

#define mfpcr(pcr)				\
({						\
	register unsigned int __val;		\
	__asm__ __volatile__ (			\
		"mfpcr %0, cr%1"		\
		: "=r" (__val)			\
		:  "i" (pcr));			\
	__val;					\
})
