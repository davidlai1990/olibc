/* autogenerated by gensyscalls.py */
#include <asm/unistd.h>
#include <linux/err.h>
#include <machine/asm.h>

ENTRY(nanosleep)
    ldr     ip, =__NR_nanosleep
    b       __bionic_syscall_eabi
END(nanosleep)
