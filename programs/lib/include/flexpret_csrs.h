#ifndef FLEXPRET_CSRS_H
#define FLEXPRET_CSRS_H

#define CSR_TOHOST 0x51e
#define CSR_FROMHOST 0x51f
#define CSR_CYCLE 0xc00
#define CSR_TIME 0xc01
#define CSR_INSTRET 0xc02
#define CSR_UARCH0 0xcc0
#define CSR_UARCH1 0xcc1
#define CSR_UARCH2 0xcc2
#define CSR_UARCH3 0xcc3
#define CSR_UARCH4 0xcc4
#define CSR_UARCH5 0xcc5
#define CSR_UARCH6 0xcc6
#define CSR_UARCH7 0xcc7
#define CSR_UARCH8 0xcc8
#define CSR_UARCH9 0xcc9
#define CSR_UARCH10 0xcca
#define CSR_UARCH11 0xccb
#define CSR_UARCH12 0xccc
#define CSR_UARCH13 0xccd
#define CSR_UARCH14 0xcce
#define CSR_UARCH15 0xccf

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
  asm volatile ("csrrw %0, " #reg ", %1" : "=r"(__tmp) : "r"(val)); \
  __tmp; })

#define set_csr(reg, bit) ({ long __tmp; \
  if (__builtin_constant_p(bit) && (bit) < 32) \
    asm volatile ("csrrs %0, " #reg ", %1" : "=r"(__tmp) : "i"(bit)); \
  else \
    asm volatile ("csrrs %0, " #reg ", %1" : "=r"(__tmp) : "r"(bit)); \
  __tmp; })

#define clear_csr(reg, bit) ({ long __tmp; \
  if (__builtin_constant_p(bit) && (bit) < 32) \
    asm volatile ("csrrc %0, " #reg ", %1" : "=r"(__tmp) : "i"(bit)); \
  else \
    asm volatile ("csrrc %0, " #reg ", %1" : "=r"(__tmp) : "r"(bit)); \
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

#endif

#endif // FLEXPRET_CSRS_H
