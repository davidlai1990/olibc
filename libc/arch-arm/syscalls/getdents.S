/* autogenerated by gensyscalls.py */
#include <asm/unistd.h>
#include <linux/err.h>
#include <machine/asm.h>

ENTRY(getdents)
    ldr     ip, =__NR_getdents64
    b       __bionic_syscall_eabi
END(getdents)
