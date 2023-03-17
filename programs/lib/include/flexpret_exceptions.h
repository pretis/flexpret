#ifndef FLEXPRET_EXCEPTIONS_H
#define FLEXPRET_EXCEPTIONS_H

/**
 * @brief All exception and interrupt causes
 * 
 */
#define EXC_CAUSE_MISALIGNED_FETCH        0x0
#define EXC_CAUSE_FAULT_FETCH             0x1
#define EXC_CAUSE_ILLEGAL_INSTRUCTION     0x2
#define EXC_CAUSE_PRIVILEGED_INSTRUCTION  0x3
#define EXC_CAUSE_FP_DISABLED             0x4
#define EXC_CAUSE_SYSCALL                 0x6
#define EXC_CAUSE_BREAKPOINT              0x7
#define EXC_CAUSE_MISALIGNED_LOAD         0x8
#define EXC_CAUSE_MISALIGNED_STORE        0x9
#define EXC_CAUSE_FAULT_LOAD              0xA
#define EXC_CAUSE_FAULT_STORE             0xB
#define EXC_CAUSE_ACCELERATOR_DISABLED    0xC
#define EXC_CAUSE_EXCEPTION_EXPIRE        0xD
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
void enable_interrupts();

/**
 * @brief Disable interrupts for thread
 * 
 */
void disable_interrupts();

/**
 * @brief Execute the interrupt on expire instruction
 * FIXME: Make into macro
 * @param timeout_ns 
 */
void interrupt_on_expire(unsigned timeout_ns);


/**
 * @brief Execute `exception_on_expire` or EE instruction
 * 
 * @param timeout_ns 
 */
void exception_on_expire(unsigned timeout_ns);

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
void setup_exceptions();


#endif
