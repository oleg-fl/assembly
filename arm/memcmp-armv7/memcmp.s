.section .text
.global main

/* int memcomp(const void *s1, const void *s2, size_t n) */
memcomp:
    push    {r11}        /* Start of the prologue. Saving Frame Pointer onto the stack */
	add     r11, sp, #0  /* Setting up the bottom of the stack frame */

    mov     r3, #0       /* index */
    mov     r4, #0       /* temp return value */

    memcomp_loop:
        ldrb    r5, [r0, r3]        /* s1[index] */
        ldrb    r6, [r1, r3]        /* s2[index] */
        cmp     r5, r6              
        movlt   r4, #-1             /* The stopping character in s1 was greater than the stopping character in s2 */  
        movgt   r4, #1              /* The stopping character in s1 was less than the stopping character in s2 */
        bne     memcomp_loop_exit
        add     r3, r3, #1          /* index++ */
        cmp     r3, r2              /* if index==n */ 
        bne     memcomp_loop

    memcomp_loop_exit:
        mov r0, r4              /* Put return value in r0 */
 
    add     sp, r11, #0  /* Start of the epilogue. Readjusting the Stack Pointer */
	pop     {r11}        /* restoring frame pointer */
	bx      lr           /* End of the epilogue. Jumping back to main via LR register */

main:
/* syscall write(int fd, const void *buf, size_t count) */
    mov     r0, #1 
    ldr     r1, =msg 
    ldr     r2, =len 
    mov     r7, #4 
    svc     #0

/* scanf */ 
    ldr     r0, =inputformat
    sub     sp, sp, #8
    mov     r1, sp
    bl      scanf

/* syscall write(int fd, const void *buf, size_t count) */
    mov     r0, #1 
    ldr     r1, =msg2 
    ldr     r2, =len2 
    mov     r7, #4 
    svc     #0

/* scanf */ 
    ldr     r0, =inputformat
    sub     sp, sp, #8
    mov     r1, sp
    bl      scanf

/* int memcmp(const void *s1, const void *s2, size_t n) */
    mov     r0, sp
    add     r1, sp, #8
    mov     r2, #4
    bl      memcomp

    cmp     r0, #0      /* Check return value */
    beq     _identical
    ldr     r1, =different
    ldr     r2, =len4
    b print_result
    _identical:
    ldr     r1, =identical
    ldr     r2, =len3
    print_result:
    mov     r0, #1 
    mov     r7, #4 
    svc     #0

/* syscall exit(int status) */
    mov     r0, #0 
    mov     r7, #1 
    svc     #0

msg:
.ascii "Enter 4 charecters and hit enter:"
len = . - msg

msg2:
.ascii "Enter 4 charecters and hit enter:"
len2 = . - msg2

identical:
.ascii "Strings are identical :)\n"
len3 = . - identical

different: 
.ascii "Strings are different :(\n"
len4 = . - different

inputformat: .asciz "%4s"
