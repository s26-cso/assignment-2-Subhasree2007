    .globl make_node
    .globl insert
    .globl get
    .globl getAtMost

    .extern malloc

# make_node(int val)
# a0 = val
make_node:
    addi sp, sp, -16
    sd ra, 8(sp)

    mv t0, a0

    li a0, 24
    call malloc

    beqz a0, make_ret

    sw t0, 0(a0)
    sd zero, 8(a0)
    sd zero, 16(a0)

make_ret:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

# insert(Node* root, int val)
# a0 = root, a1 = val
insert:
    addi sp, sp, -16
    sd ra, 8(sp)

    beqz a0, insert_make

    lw t0, 0(a0)

    blt a1, t0, go_left
    bgt a1, t0, go_right

    j insert_done

insert_make:
    mv a0, a1
    call make_node
    j insert_return

go_left:
    ld t1, 8(a0)
    mv t2, a0

    mv a0, t1
    call insert

    sd a0, 8(t2)
    mv a0, t2
    j insert_return

go_right:
    ld t1, 16(a0)
    mv t2, a0

    mv a0, t1
    call insert

    sd a0, 16(t2)
    mv a0, t2
    j insert_return

insert_done:
    # return root

insert_return:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

# get(Node* root, int val)
get:
    addi sp, sp, -16
    sd ra, 8(sp)

    beqz a0, get_null

    lw t0, 0(a0)

    beq a1, t0, get_found
    blt a1, t0, get_left

    ld a0, 16(a0)
    call get
    j get_ret

get_left:
    ld a0, 8(a0)
    call get
    j get_ret

get_found:
    j get_ret

get_null:
    li a0, 0

get_ret:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

# getAtMost(int val, Node* root)
# a0 = val, a1 = root
getAtMost:
    li t0, -1

loop:
    beqz a1, done

    lw t1, 0(a1)

    ble t1, a0, take

    ld a1, 8(a1)
    j loop

take:
    mv t0, t1
    ld a1, 16(a1)
    j loop

done:
    mv a0, t0
    ret
    