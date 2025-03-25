TARGET = main
SRC_DIR = src
SRC = $(SRC_DIR)/main.s

AS = clang
OBJCOPY = llvm-objcopy
CFLAGS = --target=riscv32-unknown-elf -nostdlib -march=rv32i -mabi=ilp32

all: $(TARGET).bin

$(TARGET).elf: $(SRC)
	$(AS) $(CFLAGS) -o $(TARGET).elf $(SRC)

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $(TARGET).elf $(TARGET).bin

clean:
	rm -f $(TARGET).elf $(TARGET).bin
