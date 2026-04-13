.section .rodata
fmt_d:  .string "%d"
fmt_sp: .string " "
fmt_nl: .string "\n"
 
.text
.globl main
main:
    # save all s-registers we use + ra
    addi    sp, sp, -64
    sd      ra, 56(sp)
    sd      s0, 48(sp)
    sd      s1, 40(sp)
    sd      s2, 32(sp)
    sd      s3, 24(sp)
    sd      s4, 16(sp)
    sd      s5,  8(sp)
    sd      s6,  0(sp)
 
    addi    s0, a0, -1          # s0 = n = argc - 1
    mv      s1, a1              # s1 = argv
 
    beqz    s0, main_done       # if n == 0, nothing to do
 
    # malloc arr[n * 4]
    slli    a0, s0, 2           # n * 4
    call    malloc
    mv      s2, a0              # s2 = arr
 
    # malloc result[n * 4]
    slli    a0, s0, 2
    call    malloc
    mv      s3, a0              # s3 = result
 
    # malloc stk[n * 4]
    slli    a0, s0, 2
    call    malloc
    mv      s4, a0              # s4 = stk
 
    li      s5, -1              # s5 = stk_top = -1 (empty stack)
 
    # Parse argv[1..n] into arr[]
    li      s6, 0               # i = 0
parse_loop:
    bge     s6, s0, parse_done
    slli    t0, s6, 3           # t0 = i * 8  (pointer size)
    addi    t0, t0, 8           # skip argv[0]
    add     t0, s1, t0          # &argv[i+1]
    ld      a0, 0(t0)           # a0 = argv[i+1]  (char*)
    call    atoi                # a0 = integer value
    slli    t0, s6, 2           # t0 = i * 4
    add     t0, s2, t0          # &arr[i]
    sw      a0, 0(t0)           # arr[i] = value
    addi    s6, s6, 1
    j       parse_loop
parse_done:
 
    # Monotonic stack: i = n-1 downto 0
    # Note: no function calls inside this loop, so t-registers are safe to use freely.
    addi    s6, s0, -1          # i = n - 1
 
nge_loop:
    bltz    s6, nge_done
 
    # t1 = arr[i]
    slli    t0, s6, 2
    add     t0, s2, t0
    lw      t1, 0(t0)           # t1 = arr[i]
 
    # Pop while stk not empty AND arr[stk[top]] <= arr[i]
pop_loop:
    bltz    s5, pop_done        # stk_top < 0 : stack empty
 
    slli    t0, s5, 2
    add     t0, s4, t0
    lw      t2, 0(t0)           # t2 = j = stk[top]  (index)
 
    slli    t0, t2, 2
    add     t0, s2, t0
    lw      t3, 0(t0)           # t3 = arr[j]
 
    bgt     t3, t1, pop_done    # arr[j] > arr[i] : stop popping
    addi    s5, s5, -1          # pop: stk_top--
    j       pop_loop
pop_done:
 
    # result[i] = stk empty ? -1 : stk[top]
    slli    t0, s6, 2
    add     t0, s3, t0          # t0 = &result[i]
    bltz    s5, store_minus1
 
    slli    t4, s5, 2
    add     t4, s4, t4
    lw      t4, 0(t4)           # t4 = stk[top] = next greater index
    sw      t4, 0(t0)
    j       push_i
 
store_minus1:
    li      t4, -1
    sw      t4, 0(t0)
 
push_i:
    # stk[++top] = i
    addi    s5, s5, 1           # stk_top++
    slli    t0, s5, 2
    add     t0, s4, t0
    sw      s6, 0(t0)           # stk[stk_top] = i
 
    addi    s6, s6, -1          # i--
    j       nge_loop
nge_done:
 
    # Print
    li      s6, 0               # i = 0
print_loop:
    bge     s6, s0, print_done
 
    beqz    s6, print_num       # no space before first element
    la      a0, fmt_sp
    call    printf
 
print_num:
    slli    t0, s6, 2
    add     t0, s3, t0
    lw      a1, 0(t0)           # result[i]
    la      a0, fmt_d
    call    printf
 
    addi    s6, s6, 1
    j       print_loop
print_done:
    la      a0, fmt_nl
    call    printf
 
main_done:
    li      a0, 0
    ld      ra, 56(sp)
    ld      s0, 48(sp)
    ld      s1, 40(sp)
    ld      s2, 32(sp)
    ld      s3, 24(sp)
    ld      s4, 16(sp)
    ld      s5,  8(sp)
    ld      s6,  0(sp)
    addi    sp, sp, 64
    ret
 