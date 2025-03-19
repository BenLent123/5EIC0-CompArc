PREFIX?=riscv32-unknown-elf-
CC=$(PREFIX)gcc
OBJCOPY=$(PREFIX)objcopy
OBJDUMP=$(PREFIX)objdump

CFLAGS ?=-march=rv32i -mabi=ilp32 -Os -g3 -static --specs=nano.specs --specs=nosys.specs -mcmodel=medany -ffunction-sections -fdata-sections -fvisibility=hidden -nostartfiles -Tlscript.ld -Wl,-v -Wl,--no-relax -Wl,--gc-sections

MEM_WORDS=131072

all: main.hex main.bin main.objdump

main: start.o xil_printf.o

main.bin: main
	$(OBJCOPY) -O binary $< $@
	
main.objdump: main
	$(OBJDUMP) -DS $< > $@

main.hex: main.bin
	./bintohex.sh $< ${MEM_WORDS} > $@

clean:
	rm -f main main.bin main.hex main.objdump start.o xil_printf.o

.PHONY: clean
