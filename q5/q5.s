.section .rodata
filename:   .string "input.txt"
msg_yes:    .string "Yes\n"
msg_no:     .string "No\n"
 
    .text
    .globl _start
_start:
    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)
    sd      s1,  8(sp)
    sd      s2,  0(sp)
    # Use 1 byte at sp-8 as read buffer
    addi    sp, sp, -8          # sp now points to 1-byte read buffer
 
    # open("input.txt", O_RDONLY=0)
    li      a0, -100            # AT_FDCWD
    la      a1, filename
    li      a2, 0               # O_RDONLY
    li      a3, 0               # mode (ignored for O_RDONLY)
    li      a7, 56              # syscall: openat
    ecall
    mv      s0, a0              # s0 = fd (check > 0 in production; skip for brevity)
 
    # lseek(fd, 0, SEEK_END) to get file size
    mv      a0, s0
    li      a1, 0
    li      a2, 2               # SEEK_END
    li      a7, 62              # syscall: lseek
    ecall
    mv      s2, a0              # s2 = file size n
 
    ; if n == 0 : trivially a palindrome
    beqz    s2, print_yes
 
    addi    s2, s2, -1          # s2 = right = n - 1
    li      s1, 0               # s1 = left  = 0
 
    # Two-pointer loop
check_loop:
    bge     s1, s2, print_yes   # left >= right : palindrome
 
    # seek to left, read 1 byte into our buffer
    mv      a0, s0
    mv      a1, s1
    li      a2, 0               # SEEK_SET
    li      a7, 62
    ecall
 
    mv      a0, s0
    mv      a1, sp              # buffer address
    li      a2, 1               # count = 1
    li      a7, 63              # syscall: read
    ecall
    lb      t0, 0(sp)           # t0 = ch_left
 
    # seek to right, read 1 byte
    mv      a0, s0
    mv      a1, s2
    li      a2, 0               # SEEK_SET
    li      a7, 62
    ecall
 
    mv      a0, s0
    mv      a1, sp
    li      a2, 1
    li      a7, 63
    ecall
    lb      t1, 0(sp)           # t1 = ch_right
 
    # compare
    bne     t0, t1, print_no    # mismatch : not a palindrome
 
    addi    s1, s1, 1           # left++
    addi    s2, s2, -1          # right--
    j       check_loop
 
print_yes:
    la      a1, msg_yes
    li      t0, 4               # length of "Yes\n"
    j       do_write
 
print_no:
    la      a1, msg_no
    li      t0, 3               # length of "No\n"
 
do_write:
    # write(1, msg, len) via syscall
    li      a0, 1               # stdout
    mv      a2, t0
    li      a7, 64              # syscall: write
    ecall
 
    # close(fd)
    mv      a0, s0
    li      a7, 57              # syscall: close
    ecall
 
    # exit(0)
    li      a0, 0
    li      a7, 93              # syscall: exit
    ecall
 