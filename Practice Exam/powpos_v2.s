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
    mv t1,x0           #set t1 to 0
    addi t1,t1,1        # set t1 to 1
    j WHILE
    
WHILE:
    beq a1,x0,DONE  #if a1 == 0 leave loop
    mul t1,t1,a0    # mult t1 = t1*a0 => d=d*a
    addi a1,a1,-1   # decrease a1 by 1 -> c=c-1
    J WHILE
DONE:
    mv a0,t1        # return d
    ret             #ret
    
