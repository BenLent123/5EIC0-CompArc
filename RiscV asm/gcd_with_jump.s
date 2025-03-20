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
    call gcd
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

gcd:                                   
    beq a0,a1,done            # beq to done when a = b
    blt a1,a0,cond              # go to cond when a0>a1 so a>b
    sub a1,a1,a0                # do b-a
    j gcd                    # callfunc gcd
    ret
cond:
    sub a0,a0,a1                # do a-b
    j gcd                    # callfunc gcd
    ret
done:
    ret                         #return
