#
#   Offcourse::RISC-V
#       - Reverse a string
#
#   Copyright: Gijs Jongenelen && e.t.s.v. Thor
#   License: GPLv3 or later
#

.data
prompt:   .ascii "Enter a word: \0"
result:   .ascii "Reversed word: \0"
newline:  .ascii "\n\0"
buffer:   .space 100

.text
.global main

main:
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, prompt
    call print_string
    la a0, buffer
    call read_string
    la a0, buffer
    call strlen
    mv s0, a0
    la a0, buffer
    li a1, 0
    addi a2, s0, -1 
    call reverse
    la a0, result
    call print_string
    la a0, buffer
    call print_string
    la a0, newline
    call print_string
    
    call exit
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

reverse:
    bge a1, a2, end_loop

rev_loop:
    add t0, a0, a1      # t0 = &str[start]
    add t1, a0, a2      # t1 = &str[end]

    lb t2, 0(t0)        # t2 = str[start]
    lb t3, 0(t1)        # t3 = str[end]

    sb t3, 0(t0)        # str[start] = str[end]
    sb t2, 0(t1)        # str[end] = str[start]

    addi a1, a1, 1      # start++
    addi a2, a2, -1     # end--

    blt a1, a2, rev_loop

end_loop:
    ret
    
