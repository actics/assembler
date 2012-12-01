nasm_flags = -g -f elf64
link_flags = -lc -m elf_x86_64 -I/lib/ld-linux-x86-64.so.2

build:
	nasm $(nasm_flags) strio.asm
	nasm $(nasm_flags) read_desc.asm
	nasm $(nasm_flags) string.asm
	ld   $(link_flags) strio.o read_desc.o string.o -o strio 
