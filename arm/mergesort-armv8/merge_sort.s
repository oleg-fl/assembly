.section .text
.global main


/* merge(arr, first, middle, last) */
merge:
    sub     sp, sp, #96
    stp     x29, x30, [sp , #80]    // 16-byte Folded Spill
    add     x29, sp, #80
    stur    x0, [x29, #-8]          // int arr[]
    stur    w1, [x29, #-12]         // int first      
    stur    w2, [x29, #-16]         // int middle
    stur    w3, [x29, #-20]         // int last

    eor     w9, w9, w9              // i, initial index of first subarray
    lsl     w9, w9, #2          
    str     w9, [sp, #0]
    eor     w10, w10, w10           // j, initial index of second subarray
    lsl     w10, w10, #2          
    str     w10, [sp, #4]
    mov     w11, w1                 // k=first, initial index of merged subarray
    lsl     w11, w11, #2          
    str     w11, [sp, #8]

    /* n1 = middle - first + 1 */
    sub     w12, w2, w1             
    add     w12, w12, #1  
    lsl     x12, x12, #2          
    str     w12, [sp, #12]          // n1, size of first subarray

    /* n2 = last - middle */
    sub     w14, w3, w2     
    lsl     x14, x14, #2
    str     w14, [sp, #16]          // n2, size of second subarray

    ldr     w0, [sp, #12]
    bl      malloc
    str     x0, [sp, #20]            // L, first subarray

    ldr     w0, [sp, #16]
    bl      malloc
    str     x0, [sp, #28]            // R, second subarray

    ldr     w14, [sp, #16]

    eor     x4, x4, x4              // x
    ldr     x0, [x29, #-8]          // arr
    ldr     w5, [x29, #-12]         // first
    lsl     w5, w5, #2              // first * 4
    add     x0, x0, x5              
    ldr     x1, [sp, #20]            // L
    copy1:
    ldr     w2, [x0, x4]            
    str     w2, [x1, x4]            // L[x] = arr[first + x]
    add     x4, x4, #4              // x++
    cmp     x4, x12                 // if (x < n1)
    blt     copy1

    eor     x4, x4, x4              // x
    ldr     x0, [x29, #-8]          // arr
    ldr     w5, [x29, #-16]         // middle
    lsl     w5, w5, #2              // middle * 4
    add     x0, x0, x5              
    add     x0, x0, #4              // arr[middle + x + 1]
    ldr     x1, [sp, #28]            // R
    copy2:
    ldr     w2, [x0, x4]            
    str     w2, [x1, x4]            // R[x] = arr[middle + x + 1]
    add     x4, x4, #4              // i++
    cmp     x4, x14                 // if (x < n2)
    blt     copy2

    ldr     x0, [x29, #-8]          // arr
    ldr     x1, [sp, #20]            // L, first subarray
    ldr     x2, [sp, #28]            // R, second subarray
    ldr     w11, [sp, #8]           // k
    l1:
    cmp     w9, w12
    bge     l2
    cmp     w10, w14
    bge     l2                      // while (i < n1 && j < n2)

    ldr     w3, [x1, x9]            // L[i]
    ldr     w4, [x2, x10]           // R[j]
    cmp     w3, w4
    bgt     l11 

    str     w3, [x0, x11]            // arr[k] = L[i]
    add     x11, x11, #4             // k++
    add     x9, x9, #4               // i++
    b       l1

    l11:
    str     w4, [x0, x11]           // arr[k] = R[j]
    add     x11, x11, #4            // k++
    add     x10, x10, #4            // j++
    b       l1

    l2:
    cmp     w9, w12
    bge     l3                      // if (i>=n1)
    ldr     w3, [x1, x9]            // L[i]
    str     w3, [x0, x11]           // arr[k] = L[i]
    add     x9, x9, #4              // i++
    add     x11, x11, #4            // k++
    b       l2

    l3:
    cmp     w10, w14
    bge     _merge_exit             // if (j>=n2)
    ldr     w3, [x2, x10]           // R[j]
    str     w3, [x0, x11]           // arr[k] = R[j]
    add     x10, x10, #4            // j++
    add     x11, x11, #4            // k++
    b       l3

    _merge_exit:

    ldp     x29, x30, [sp, #80]     // 16-byte Folded Reload
    add     sp, sp, #96             
    ret


/* void mergeSort(int arr[], int first, int last) */
mergeSort:
    sub     sp, sp, #48
    stp     x29, x30, [sp , #32]    // 16-byte Folded Spill
    add     x29, sp, #32
    stur    x0, [x29, #-8]          // int arr[]
    stur    w1, [x29, #-12]         // int first      
    stur    w2, [x29, #-16]          // int last

    /* if (first >= last) */ 
    cmp     w1, w2
    bge     _mergeSort_exit     

    /* middle = first + (last - first) / 2 */
    sub     w4, w2, w1
    lsr     w4, w4, #1
    add     w4, w4, w1
    stur    w4, [sp] 

    /* mergeSort(arr, first, middle) */
    ldur    x0, [x29, #-8]
    ldur    w1, [x29, #-12]
    ldr     w2, [sp]
    bl      mergeSort

    /* mergeSort(arr, middle + 1, last) */
    ldur    x0, [x29, #-8]
    ldr     w1, [sp]
    add     w1, w1, #1
    ldur    w2, [x29, #-16]
    bl      mergeSort

    /* merge(arr, first, middle, last) */
    ldur    x0, [x29, #-8]
    ldur    w1, [x29, #-12]
    ldr     w2, [sp]
    ldur    w3, [x29, #-16]
    bl      merge

    /* printArray(int *arr, int length) */
    ldr     x0, =array
    ldr     x1, =size
    lsr     x1, x1, #2
    bl      printArray

    _mergeSort_exit:

    ldp     x29, x30, [sp, #32]     // 16-byte Folded Reload
    add     sp, sp, #48             // =48
    ret
    

/* void printArray(int *arr, int length) */
printArray:
    sub     sp, sp, #48
    stp     x29, x30, [sp , #32]    // 16-byte Folded Spill
    add     x29, sp, #32
    stur    x0, [x29, #-8]          // int arr[]
    stur    w1, [x29, #-12]         // int length  

    eor     w10, w10, w10           // i
    str     w10, [sp]

    _print_member:            
    ldr     w12, [x29, #-12]              
    cmp     w10, w12
    bge     _print_array_exit

    ldr     x13, [x29, #-8]
    ldr     w1, [x13], #4
    str     x13, [x29, #-8]
    ldr     x0, =printfmt
    bl      printf

    ldr     w10, [sp]
    add     w10, w10, #1
    str     w10, [sp]
    b       _print_member      

    _print_array_exit:
    mov     x0, 10              // print new line
    bl      putchar

    ldp     x29, x30, [sp, #32]     // 16-byte Folded Reload
    add     sp, sp, #48             // =48
    ret


main:
/* syscall write(int fd, const void *buf, size_t count) */
    mov     x0, #1     
    ldr     x1, =msg 
    ldr     x2, =len 
    mov     w8, #64 
    svc     #0

    ldr     x0, =array
    ldr     x1, =size
    lsr     x1, x1, #2

    bl      printArray

/* void mergeSort(int arr[], int first, int last) */
    ldr     x0, =array
    eor     x1, x1, x1
    mov     x2, #12
    bl  mergeSort


/* syscall exit(int status) */
    mov     x0, #0 
    mov     w8, #93 
    svc     #0

.section .data
msg:
.ascii "Merge Sort in ARM64!\n"
len = . - msg

array:
.word 38, 27, 43, 3, 9, 82, 1, 12, 45,2,90,3,400
size = . - array

printfmt:
.ascii "%d "


