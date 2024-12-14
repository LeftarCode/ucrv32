NAME = loop
ARCH = riscv32
CC = $(ARCH)-unknown-elf-gcc
LD = $(ARCH)-unknown-elf-ld
OBJCOPY = $(ARCH)-unknown-elf-objcopy
CFLAGS = -nostdlib -nostartfiles
IDIR = inc
SDIR = src
BDIR = build
S_SRCS = $(wildcard $(SDIR)/*.s)
C_SRCS = $(wildcard $(SDIR)/*.c)
S_OBJS = $(S_SRCS:$(SDIR)/%.s=$(BDIR)/%_asm.o)
C_OBJS = $(C_SRCS:$(SDIR)/%.c=$(BDIR)/%.o)


all: clean directories $(NAME).img

directories:
	mkdir -p build

$(NAME).img: $(NAME).elf
	@mkdir -p $(@D)
	$(OBJCOPY) $(BDIR)/$(NAME).elf -I binary $(BDIR)/$(NAME).img

$(NAME).elf: $(S_OBJS) link.ld $(C_OBJS)
	$(LD) -T link.ld -o $(BDIR)/$(NAME).elf $(S_OBJS) $(C_OBJS)

$(BDIR)/%.o: $(SDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BDIR)/%_asm.o: $(SDIR)/%.s
	$(CC) $(SFLAGS) -c $< -o $@

clean:
	rm -f $(BDIR)/*_asm.o $(BDIR)/*.o $(BDIR)/$(NAME).elf $(BDIR)/$(NAME).img

run-spike: all
	spike -d --isa=rv32imc_zicntr --log-commits $(BDIR)/$(NAME).elf
