build:
	nasm -f elf cpfile.asm
	nasm -f elf ask_and_open.asm
	nasm -f elf copy_file.asm
	ld -m elf_i386 cpfile.o ask_and_open.o copy_file.o -o cpfile
