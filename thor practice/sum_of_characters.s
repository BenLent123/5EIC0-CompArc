#
#   Offcourse::RISC-V
#       - Sum of characters
#
#   Copyright: Gijs Jongenelen && e.t.s.v. Thor
#   License: GPLv3 or later
#

.data
prompt:   .ascii "Enter a word: \0"
result:   .ascii "Sum of ASCII values: \0"
newline:  .ascii "\n\0"
buffer:   .space 100

.text
.global main

main:
    la a0, prompt
    call print_string
    la a0, buffer
    call read_string
    la a0, buffer
    call sum_of_ASCII
    mv s0, a0
    la a0, result
    call print_string
    mv a0, s0
    call print_int
    la a0, newline
    call print_string
    call exit
    ret

sum_of_ASCII:
    li t0,0     #sum
    li t1,0     #i
    j while
    
while:
    addi sp,sp,-4
    sw ra,0(sp)
    
    
    add t2,a0,t1  # find str[i]
    lb t3,0(t2)     # load str[i]
    beq t3,x0,end   # if str[i] is null
    add t0,t0,t3    # sum = sum+val
    addi t1,t1,1    # increment i str[i] -> str[i+1]
    
    call while
    
    lw ra,0(sp)
    addi sp,sp,4
    
    ret
end:
    mv a0,t0
    ret
