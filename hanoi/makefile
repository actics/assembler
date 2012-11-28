nasm_flags = -g -f elf64
link_flags = -lc -m elf_x86_64 -I/lib/ld-linux-x86-64.so.2

build:
	nasm $(nasm_flags) hanoi.asm
	nasm $(nasm_flags) hanoi_towers.asm
	ld   $(link_flags) hanoi.o hanoi_towers.o -o hanoi
