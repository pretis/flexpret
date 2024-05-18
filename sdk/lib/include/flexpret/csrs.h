#ifndef FLEXPRET_CSRS_H
#define FLEXPRET_CSRS_H

#define CSR_EPC         0x502
#define CSR_SLOTS       0x503
#define CSR_IMEM_PROT   0x505
#define CSR_EVEC        0x508 
#define CSR_CAUSE       0x509 
#define CSR_STATUS      0x50a
#define CSR_COREID      0x510
#define CSR_TMODES      0x504

#define CSR_HARTID      0x50b

#define CSR_FROMHOST    0x51f
#define CSR_TOHOST_BASE 0x530
#define CSR_TOHOST(tid) (CSR_TOHOST_BASE + tid)

#define CSR_HWLOCK      0x520
#define CSR_COMPARE_DU_WU 0x521
#define CSR_COMPARE_IE_EE 0x522

#define CSR_CYCLE       0xc00
#define CSR_TIME        0xc01
#define CSR_INSTRET     0xc02

#define CSR_UARCH0      0xcc0
#define CSR_UARCH1      0xcc1
#define CSR_UARCH2      0xcc2
#define CSR_UARCH3      0xcc3
#define CSR_UARCH4      0xcc4
#define CSR_UARCH5      0xcc5
#define CSR_UARCH6      0xcc6
#define CSR_UARCH7      0xcc7
#define CSR_UARCH8      0xcc8
#define CSR_UARCH9      0xcc9
#define CSR_UARCH10     0xcca
#define CSR_UARCH11     0xccb
#define CSR_UARCH12     0xccc
#define CSR_UARCH13     0xccd
#define CSR_UARCH14     0xcce
#define CSR_UARCH15     0xccf
#define CSR_CONFIGHASH  0xcd0

#define CSR_COUNTH      0x586
#define CSR_CYCLEH      0xc80
#define CSR_TIMEH       0xc81
#define CSR_INSTRETH    0xc82

#ifdef __ASSEMBLY__
#define __ASM_STR(x)	x
#else
#define __ASM_STR(x)	#x
#endif

#ifndef __ASSEMBLER__

#define read_csr(reg) ({ long __tmp; \
  asm volatile ("csrr %0, " __ASM_STR(reg) : "=r"(__tmp)); \
  __tmp; })

#define write_csr(reg, val) \
  asm volatile ("csrw " __ASM_STR(reg) ", %0" :: "r"(val))

#define swap_csr(reg, val) ({ long __tmp; \
  asm volatile ("csrrw %0, " __ASM_STR(reg) ", %1" : "=r"(__tmp) : "r"(val)); \
  __tmp; })

#define set_csr(reg, bit) ({ long __tmp; \
  if (__builtin_constant_p(bit) && (bit) < 32) \
    asm volatile ("csrrs %0, " __ASM_STR(reg) ", %1" : "=r"(__tmp) : "i"(bit)); \
  else \
    asm volatile ("csrrs %0, " __ASM_STR(reg) ", %1" : "=r"(__tmp) : "r"(bit)); \
  __tmp; })

#define clear_csr(reg, bit) ({ long __tmp; \
  if (__builtin_constant_p(bit) && (bit) < 32) \
    asm volatile ("csrrc %0, " __ASM_STR(reg) ", %1" : "=r"(__tmp) : "i"(bit)); \
  else \
    asm volatile ("csrrc %0, " __ASM_STR(reg) ", %1" : "=r"(__tmp) : "r"(bit)); \
  __tmp; })

#define rdtime() ({ unsigned long __tmp; \
  asm volatile ("rdtime %0" : "=r"(__tmp)); \
  __tmp; })

#define rdcycle() ({ unsigned long __tmp; \
  asm volatile ("rdcycle %0" : "=r"(__tmp)); \
  __tmp; })

#define rdinstret() ({ unsigned long __tmp; \
  asm volatile ("rdinstret %0" : "=r"(__tmp)); \
  __tmp; })

#define rdlinkreg() ({ unsigned long *__tmp; \
  asm volatile ("addi %0, ra, 0" : "=r"(__tmp)); \
  __tmp; })

#define rdstackptr() ({ unsigned long *__tmp; \
  asm volatile ("addi %0, sp, 0" : "=r"(__tmp)); \
  __tmp; })

#endif

#define read_coreid() read_csr(CSR_COREID)

#define read_hartid() (uint32_t) read_csr(CSR_HARTID)

#endif // FLEXPRET_CSRS_H
