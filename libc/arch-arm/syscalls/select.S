/* autogenerated by gensyscalls.py */
#include <asm/unistd.h>
#include <linux/err.h>
#include <machine/asm.h>

ENTRY(select)
    ldr     ip, =__NR__newselect
    b       __bionic_long_syscall_eabi
END(select)
