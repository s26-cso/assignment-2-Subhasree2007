.text
.globl make_node
make_node:
    addi    sp, sp, -16
    sd      ra,  8(sp)
    sd      s0,  0(sp)
 
    mv      s0, a0              # s0 = val
 
    li      a0, 24              # sizeof(Node) = 24
    call    malloc              # a0 = pointer to new node
 
    sw      s0,  0(a0)          # node->val   = val
    sd      zero, 8(a0)         # node->left  = NULL
    sd      zero, 16(a0)        # node->right = NULL
 
    ld      ra,  8(sp)
    ld      s0,  0(sp)
    addi    sp, sp, 16
    ret

# struct Node* insert(struct Node* root, int val)
#   a0 = root,  a1 = val
#   returns: a0 = (possibly new) root
.globl insert
insert:
    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)            # s0 = root
    sd      s1,  8(sp)            # s1 = val
 
    mv      s0, a0                # s0 = root
    mv      s1, a1                # s1 = val
 
    # if root == NULL, make a new node and return it
    bnez    s0, insert_nonempty
    mv      a0, s1
    call    make_node             # returns new node in a0
    j       insert_done
 
insert_nonempty:
    lw      t0, 0(s0)             # t0 = root->val
    beq     t0, s1, insert_equal  # val == root->val
    blt     t0, s1, insert_right  # root->val < val
 
insert_left:
    ld      a0, 8(s0)             # a0 = root->left
    mv      a1, s1
    call    insert
    sd      a0, 8(s0)             # root->left = returned node
    j       insert_return_root
 
insert_right:
    ld      a0, 16(s0)            # a0 = root->right
    mv      a1, s1
    call    insert
    sd      a0, 16(s0)            # root->right = returned node
 
insert_equal:
insert_return_root:
    mv      a0, s0                # return original root
 
insert_done:
    ld      ra, 24(sp)
    ld      s0, 16(sp)
    ld      s1,  8(sp)
    addi    sp, sp, 32
    ret

# struct Node* get(struct Node* root, int val)
#   a0 = root,  a1 = val
#   returns: a0 = pointer to matching node, or NULL
.globl get
get:
    addi    sp, sp, -16
    sd      ra, 8(sp)
 
    # Base case: root == NULL -> return NULL
    beqz    a0, get_done
 
    lw      t0, 0(a0)           # t0 = root->val
    beq     t0, a1, get_done    # found: return current node
    blt     t0, a1, get_right   # root->val < val: search right
 
get_left:
    ld      a0, 8(a0)           # a0 = root->left
    call    get
    j       get_done
 
get_right:
    ld      a0, 16(a0)          # a0 = root->right
    call    get
 
get_done:
    ld      ra, 8(sp)
    addi    sp, sp, 16
    ret

# int getAtMost(int val, struct Node* root)
#   a0 = val,  a1 = root
#   returns: a0 = greatest tree value <= val, or -1
.globl getAtMost
getAtMost:
    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)          # s0 = val
    sd      s1,  8(sp)          # s1 = root
 
    mv      s0, a0              # s0 = val
    mv      s1, a1              # s1 = root
 
    # if root == NULL, return -1
    bnez    s1, getatmost_nonempty
    li      a0, -1
    j       getatmost_done
 
getatmost_nonempty:
    lw      t0, 0(s1)           # t0 = root->val
 
    # if val < root->val: answer can only be in left subtree
    blt     s0, t0, getatmost_left
 
    # val >= root->val: root->val is a valid candidate.
    # Try right subtree for something even closer
    mv      a0, s0              # val
    ld      a1, 16(s1)          # root->right
    call    getAtMost
 
    # if right subtree returned something valid, it's a better answer
    li      t1, -1
    bne     a0, t1, getatmost_done   # right found something: return it
 
    # right had nothing: use root->val as the answer
    lw      a0, 0(s1)
    j       getatmost_done
 
getatmost_left:
    mv      a0, s0              # val
    ld      a1, 8(s1)           # root->left
    call    getAtMost
    # a0 = result from left (could be -1)
 
getatmost_done:
    ld      ra, 24(sp)
    ld      s0, 16(sp)
    ld      s1,  8(sp)
    addi    sp, sp, 32
    ret
 
