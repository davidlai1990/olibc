/* autogenerated by gensyscalls.py */
#include <asm/unistd.h>
#include <linux/err.h>
#include <machine/asm.h>

ENTRY(remap_file_pages)
    pushl   %ebx
    pushl   %ecx
    pushl   %edx
    pushl   %esi
    pushl   %edi
    mov     24(%esp), %ebx
    mov     28(%esp), %ecx
    mov     32(%esp), %edx
    mov     36(%esp), %esi
    mov     40(%esp), %edi
    movl    $__NR_remap_file_pages, %eax
    int     $0x80
    cmpl    $-MAX_ERRNO, %eax
    jb      1f
    negl    %eax
    pushl   %eax
    call    __set_errno
    addl    $4, %esp
    orl     $-1, %eax
1:
    popl    %edi
    popl    %esi
    popl    %edx
    popl    %ecx
    popl    %ebx
    ret
END(remap_file_pages)
