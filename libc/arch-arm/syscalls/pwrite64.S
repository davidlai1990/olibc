/* autogenerated by gensyscalls.py */
#include <asm/unistd.h>
#include <linux/err.h>
#include <machine/asm.h>

ENTRY(pwrite64)
    ldr     ip, =__NR_pwrite64
    b       __bionic_long_syscall_eabi
END(pwrite64)
