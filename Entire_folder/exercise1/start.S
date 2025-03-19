.section .text.init
.global _start
.extern _stack_start
.global outbyte

_start:
	la a0, __bss_start
	la a1, __BSS_END__
	bge a0, a1, end_init_bss
loop_init_bss:
	sw zero, 0(a0)
	addi a0, a0, 4
	blt a0, a1, loop_init_bss
end_init_bss:

	li x1, 0
	li x2, 0
	li x3, 0
	li x4, 0
	li x5, 0
	li x6, 0
	li x7, 0
	li x8, 0
	li x9, 0
	li x10,0
	li x11,0
	li x12,0
	li x13,0
	li x14,0
	li x15,0
	li x16,0
	li x17,0
	li x18,0
	li x19,0
	li x20,0
	li x21,0
	li x22,0
	li x23,0
	li x24,0
	li x25,0
	li x26,0
	li x27,0
	li x28,0
	li x29,0
	li x30,0
	li x31,0

	la sp, _stack_start
	jal main

    li t1, 1
    sw t1, tohost, t0

_loop:
    #li t0, -4
	lui t0, 0x80000
    sw a0, 0(t0)
	j _loop;

outbyte:
	lui a5,0xe0000
	sb  a0,0x030(a5)
	ret

#if defined(LOAD_BICYCLE) || defined(LOAD_FOOTBALL) || defined(LOAD_RENATA) || defined(LOAD_CARGATE)
.section image_section
.align 2
image:
#if defined(LOAD_BICYCLE)
.incbin "bicycle.y"
#elif defined(LOAD_FOOTBALL)
.incbin "football.y"
#elif defined(LOAD_RENATA)
.incbin "renata.y"
#elif defined(LOAD_CARGATE)
.incbin "cargate.y"
#endif
#endif

.section ".tohost","aw",@progbits
.align 6
.globl tohost
tohost: .dword 0
.align 6
.globl fromhost
fromhost: .dword 0
