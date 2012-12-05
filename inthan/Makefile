obj-m := test.o
test-objs := inthan.o module.o
KVERSION = $(shell uname -r)
inthan.o: inthan.asm
	nasm -f elf64 -o $@ $^

build:
	make -C /lib/modules/$(KVERSION)/build M=$(PWD) modules
