extern malloc
extern free
extern printf
extern putchar

section .data		; Data section, initialized variables
    array: dq 38, 27, 43, 3, 9, 82, 1, 12, 44, 6324, 5, 6, 7, 11, 42, 80, 3
    len:   dw 17
    printfmt: db "%d ", 0

section .text           ; Code section.

    global  main		; the standard gcc entry point

; Merges two subarrays of arr[].
; First subarray is arr[first..middle]
; Second subarray is arr[middle+1..last]
merge:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 0x50         
    mov     [rbp-0x38], rdi   ; push 1st argument to stack (arr)
    mov     [rbp-0x3c], esi   ; push 2nd argument to stack (first index)
    mov     [rbp-0x40], edx   ; push 3rd argument to stack (middle index)
    mov     [rbp-0x44], ecx   ; push 4th argument to stack (last index)

    xor     eax, eax
    mov     [rbp-0x4],  eax     ; i, initial index of first subarray
    mov     [rbp-0x8],  eax     ; j, initial index of second subarray
    mov     [rbp-0xc],  esi     ; k=last, initial index of merged subarray
    
    ; n1 = middle - first + 1
    mov     eax, [rbp-0x40]
    sub     eax, [rbp-0x3c]
    inc     eax
    mov     [rbp-0x10], eax   ; n1, size of first subarray
 
    ; n2 = last - middle
    mov     eax, [rbp-0x44]
    sub     eax, [rbp-0x40]
    mov     [rbp-0x14], eax   ; n2, size of second subarray

    mov     edi, [rbp-0x10]   ; n1
    shl     edi, 3            ; n1 * 8
    call    malloc
    mov     [rbp-0x1c], rax   ; L, first subarray

    mov     edi, [rbp-0x14]   ; n1
    shl     edi, 3            ; n1 * 8
    call    malloc
    mov     [rbp-0x24], rax   ; R, second subarray
    
    mov     rax, qword [rbp-0x38]   ; arr
    mov     ebx, [rbp-0x3c]         ; first
    cld                             ; scan in the forward direction
    mov     rdi, [rbp-0x1c]         ; *dest
    lea     rsi, [rax + rbx*8]      ; *src
    mov     ecx, [rbp-0x10]         ; size_t n
    rep movsq                       ; copy rcx qword elements from array to subarray L

    mov     rax, qword [rbp-0x38]   ; arr
    mov     ebx, [rbp-0x40]         ; middle
    inc     rbx                     ; middle++
    cld                             ; scan in the forward direction
    mov     rdi, [rbp-0x24]         ; *dest
    lea     rsi, [rax + rbx*8]      ; *src
    mov     ecx, [rbp-0x14]         ; size_t n
    rep movsq                       ; copy rcx qword elements from array to subarray R

    mov     r9,  [rbp-0x38]        ; arr
    mov     r10, [rbp-0x1c]        ; L, first subarray
    mov     r11, [rbp-0x24]        ; R, second subarray
    mov     r8d, [rbp-0xc]         ; k

    l1:
        mov     eax, [rbp-0x4]    ; i
        cmp     eax, [rbp-0x10]     
        jge     l2                  
        mov     ebx, [rbp-0x8]    ; j
        cmp     ebx, [rbp-0x14]
        jge     l2                      ; while (i < n1 && j < n2)

        mov     rcx, [r10 + rax*8]          ; L[i]
        mov     rdx, [r11 + rbx*8]          ; R[j]
        cmp     rcx, rdx 
        jg      l11

        mov     [r9 + r8*8], rcx        ; arr[k] = L[i]
        inc     eax                     ; i++
        mov     [rbp-0x4], eax
        inc     r8                      ; k++
        mov     [rbp-0xc], r8d
        jmp     l1
        
        l11: 
        mov     [r9 + r8*8], rdx        ; arr[k] = R[j]
        inc     ebx                     ; j++
        mov     [rbp-0x8], ebx
        inc     r8                      ; k++
        mov     [rbp-0xc], r8d
        
    jmp     l1

    
    l2:
    mov     eax, [rbp-0x4]              ; i
    cmp     eax, [rbp-0x10]             ; if (i>=n1)
    jge     l3

    mov     rdx, [r10 + rax*8]          ; L[i]
    mov     [r9 + r8*8], rdx            ; arr[k] = L[i]
    inc     eax                         ; i++
    mov     [rbp-0x4], eax
    inc     r8                          ; k++
    mov     [rbp-0xc], r8d
    jmp     l2


    l3:
    mov     ebx, [rbp-0x8]              ; j
    cmp     ebx, [rbp-0x14]             ; if (j>=n2)
    jge     _merge_exit

    mov     rcx, [r11 + rbx*8]          ; R[j]
    mov     [r9 + r8*8], rcx            ; arr[k] = L[i]
    inc     ebx                         ; j++
    mov     [rbp-0x8], ebx
    inc     r8                          ; k++
    mov     [rbp-0xc], r8d
    jmp     l3


    _merge_exit:

    mov     rax, [rbp-0x1c]             ; free L   
    mov     rdi, rax
    call    free

    mov     rax, [rbp-0x24]             ; free R
    mov     rdi, rax
    call    free

    mov     rsp, rbp
    pop     rbp
    ret   



mergeSort:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 0x20
    mov     [rbp-0x18], rdi   ; push 1st argument to stack (arr)
    mov     [rbp-0x1c], esi   ; push 2nd argument to stack (first index)
    mov     [rbp-0x20], edx   ; push 3rd argument to stack (last index)

    ; if (first >= last)
    mov     eax, [rbp-0x1c]
    cmp     eax, [rbp-0x20]
    jge     _mergeSort_exit

    ; middle = first + (last - first) / 2
    mov     eax, [rbp-0x20]
    sub     eax, [rbp-0x1c]
    shr     eax, 1
    add     eax, [rbp-0x1c]
    mov     [rbp-0x4], eax    ; store result to local variable, middle  

    ; mergeSort(arr, first, middle)
    mov     edx, [rbp-0x4]    ; middle
    mov     esi, [rbp-0x1c]   ; first
    mov     rdi, [rbp-0x18]   ; arr
    call    mergeSort

    ; mergeSort(arr, middle + 1, last)
    mov     edx, [rbp-0x20]   ; last
    mov     esi, [rbp-0x4]    ; middle + 1
    inc     esi
    mov     rdi, [rbp-0x18]   ; arr
    call    mergeSort

    ; merge(arr, first, middle, last)
    mov     ecx, [rbp-0x20]   ; last
    mov     edx, [rbp-0x4]    ; middle
    mov     esi, [rbp-0x1c]   ; first
    mov     rdi, [rbp-0x18]   ; arr
    call    merge

    movzx   rdx, word [len] ; 2nd argument array length
    mov     rsi, rdx
    lea     rdi, [array]    ; 1st argument (array address)
    call    printArray

    _mergeSort_exit:
    mov     rsp, rbp
    pop     rbp
    ret   


printArray:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 0x20
    mov     [rbp-0x18], rdi     ; arr, 1st argument
    mov     [rbp-0x1c], esi     ; length, 2nd argument

    xor     rbx, rbx
    mov     [rbp-0x8], rbx      ; i

    _print_member:
    mov     rdx, [rbp-0x18]     ; arr
    cmp     ebx, [rbp-0x1c]     ; if (i>=length)
    jge     _print_array_exit
    mov	    rdi, printfmt       
    mov     rsi, [rdx + rbx*8]  ; arr[i]
	xor     rax, rax
    
    call    printf wrt ..plt	; Call C function printf
    mov     rbx, [rbp-0x8]
    inc     rbx
    mov     [rbp-0x8], rbx
    jmp     _print_member

    _print_array_exit:
    mov     edi, 10         ; print new line
    call    putchar

    mov     rsp, rbp
    pop     rbp
    ret   

main:				    
    sub     rsp, 8
    mov     rbp, rsp

    movzx   rdx, word [len] ; 2nd argument array length
    mov     rsi, rdx
    lea     rdi, [array]    ; 1st argument (array address)
    call    printArray

    movzx   rdx, word [len] ; 3rd argument, len - 1 (last index)
    xor     rsi, rsi        ; 2nd argument, 0 (first index)
    lea     rdi, [array]    ; 1st argument (array address)
    call    mergeSort

    movzx   rdx, word [len] ; 2nd argument array length
    mov     rsi, rdx
    lea     rdi, [array]    ; 1st argument (array address)
    call    printArray


    mov	    rax, 0		    ; normal, no error, return value
	ret    