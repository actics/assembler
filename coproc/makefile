nasm_flags = -g -f elf64
link_flags = -lc -m elf_x86_64 -I/lib/ld-linux-x86-64.so.2

build:
	nasm $(nasm_flags) coproc.asm
	ld   $(link_flags) coproc.o -o coproc
