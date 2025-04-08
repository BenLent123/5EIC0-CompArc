.data
str1:    .asciz "Input number: "
str2:    .asciz "result = "

.section .text

.global main
main:
  addi sp, sp, -4
  sw ra, 0(sp)
  la a0, str1
  call print_string

  call read_int

  call fibonacci

  mv s1, a0
  la a0,str2
  call print_string

  mv a0,s1
  call print_int
  call exit
  ret
 
fibonacci:
    addi sp, sp, -16       # push stack 
    sw ra, 12(sp)          # Save ra
    sw a0, 8(sp)           # Save initial a0

    li t0,1
    beq a0, x0, ret1  # go to ret1 if a0==0
    beq a0, t0, ret1  # go to ret1 if a0==1
    
    lw a0, 8(sp)         # load initial a0
    addi a0, a0, -1         # do a0-1
    call fibonacci         # fib(a0 = a0-1) 
    sw a0, 0(sp)              # Save fib(a0=a0-1)

    lw a0, 8(sp)           # Restore original a0
    addi a0, a0, -2         # do a0-2
    call fibonacci         # fib(a0 = a0-2)
    sw a0,4(sp)             # save fib(a0=a0-2)
    
    lw t1,0(sp)
    lw t2,4(sp)
    add a0, t1, t2         # fib(a0) = fib(a0-1) + fib(a0-2)

    lw ra, 12(sp)          # load ra
    addi sp, sp, 16        # pop stack
    
    ret

ret1:
    li a0, 1               # Return 1
    
    lw ra, 12(sp)
    addi sp, sp, 16
    ret
    
