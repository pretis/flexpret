#ifndef FLEXPRET_EXCEPTIONS_H
#define FLEXPRET_EXCEPTIONS_H

/**
 * @brief All exception and interrupt causes
 * 
 */
#define EXC_CAUSE_MISALIGNED_FETCH        0x00
#define EXC_CAUSE_FAULT_FETCH             0x01
#define EXC_CAUSE_ILLEGAL_INSTRUCTION     0x02
#define EXC_CAUSE_PRIVILEGED_INSTRUCTION  0x03
#define EXC_CAUSE_FP_DISABLED             0x04
#define EXC_CAUSE_SYSCALL                 0x06
#define EXC_CAUSE_BREAKPOINT              0x07
#define EXC_CAUSE_MISALIGNED_LOAD         0x08
#define EXC_CAUSE_MISALIGNED_STORE        0x09
#define EXC_CAUSE_FAULT_LOAD              0x0A
#define EXC_CAUSE_FAULT_STORE             0x0B
#define EXC_CAUSE_ACCELERATOR_DISABLED    0x0C
#define EXC_CAUSE_EXCEPTION_EXPIRE        0x0D
#define EXE_CAUSE_EXT_INTERRUPT0          0x10
#define EXE_CAUSE_EXT_INTERRUPT1          0x11
#define EXE_CAUSE_EXT_INTERRUPT2          0x12
#define EXE_CAUSE_EXT_INTERRUPT3          0x13
#define EXE_CAUSE_EXT_INTERRUPT4          0x14
#define EXE_CAUSE_EXT_INTERRUPT5          0x15
#define EXE_CAUSE_EXT_INTERRUPT6          0x16
#define EXE_CAUSE_TIMER_INTERRUPT         0x17

#define EXC_CAUSE_INTERRUPT_EXPIRE        0x8000000D
#define EXC_CAUSE_EXTERNAL_INT            0x8000000E

/**
 * @brief Interrupt Service Routine (ISR) function prototype
 * 
 */
typedef void (*isr_t)(void);

/**
 * @brief Enable interrupts for thread
 * 
 */
#define ENABLE_INTERRUPTS() do { \
    set_csr(CSR_STATUS, 0x10); \
} while(0)

/**
 * @brief Disable interrupts for thread
 * 
 */
#define DISABLE_INTERRUPTS() do { \
    clear_csr(CSR_STATUS, 0x10); \
} while(0)

/**
 * @brief Execute the interrupt on expire instruction
 * @param timeout_ns 
 */
#define INTERRUPT_ON_EXPIRE(ns) do { \
    write_csr(CSR_COMPARE_IE_EE, ns); \
    __asm__ volatile(".word 0x0200705B;"); \
} while(0)

/**
 * @brief Execute `EXCEPTION_ON_EXPIRE` or EE instruction
 * 
 * @param timeout_ns 
 */
#define EXCEPTION_ON_EXPIRE(ns) do { \
    write_csr(CSR_COMPARE_IE_EE, ns); \
    __asm__ volatile(".word 0x0000705B;"); \
} while(0)

/**
 * @brief Register an ISR handler for one of the IRQ sources
 * 
 * @param cause 
 * @param isr 
 */
void register_isr(int cause, isr_t isr);

/**
 * @brief Set the up exception handling. Should be called for each thread
 * 
 */
void setup_exceptions(void);

#define STACK_GUARD_INITVAL (0xDEADBEEF)


#endif
