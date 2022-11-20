CC=gcc
CFLAGS= -ggdb -m64 -no-pie

all: merge_sort

merge_sort.o: merge_sort.asm
	nasm -f elf64 -F dwarf -g -l merge_sort.lst merge_sort.asm

merge_sort: merge_sort.o
	$(CC) $(CFLAGS) -o merge_sort merge_sort.o