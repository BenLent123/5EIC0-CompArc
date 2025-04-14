.data
str1:    .ascii "result = \0"
str2:    .ascii "\n\0"

.text

.global main

main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	call read_int
    mv s0,a0
	call read_int
    mv s1,a0
    mv a0,s0
    mv a1,s1
    call powpos
    mv s1,a0
    la a0,str1
    call print_string
    mv a0,s1
    call print_int
    la a0,str2
    call print_string
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	call show_pc
	call exit
    ret

powpos:
    li t0,1
    
    beq a1,x0,res
    
    bne a1,x0,cycle
    
    ret
cycle:
    addi sp,sp,-4
    sw ra,0(sp)
    
    beq a1,x0,res
    
    mul t0,t0,a0
    addi a1,a1,-1
    
    call cycle
    
    lw ra,0(sp)
    addi sp,sp,4
    
    ret

res:
    mv a0,t0
    ret
    
