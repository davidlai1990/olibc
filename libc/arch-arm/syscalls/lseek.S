/* autogenerated by gensyscalls.py */
#include <asm/unistd.h>
#include <linux/err.h>
#include <machine/asm.h>

ENTRY(lseek)
    ldr     ip, =__NR_lseek
    b       __bionic_syscall_eabi
END(lseek)
