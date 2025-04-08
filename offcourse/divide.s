.data
str1:    .ascii "result = \0"
str2:    .ascii "\n\0"

.text

.global main
main:
	call read_int
    mv s0,a0
	call read_int
    mv s1,a0
    mv a0,s0
    mv a1,s1
    call divide
    mv s1,a0
    la a0,str1
    call print_string
    mv a0,s1
    call print_int
    la a0,str2
    call print_string
	call exit
    ret
 
divide:
    addi sp,sp,-4  #push stack
    sw ra,0(sp)     #save ra
    
    blt a0,a1,COND  #go to cond if b>a
    sub a0,a0,a1    # a = a-b
    
    
    call divide     #call devide
    
    addi a0,a0,1    # add 1 to function output
    
    lw ra, 0(sp)    #load ra
    addi sp,sp,4    #pop stack
    ret
COND:
    mv a0,x0        #set a0 to 0 

    lw ra, 0(sp)    #load ra
    addi sp,sp,4    #pop stack
    ret
