all: merge_sort

merge_sort.o: merge_sort.s
	aarch64-linux-gnu-as --gdwarf-2 merge_sort.s -o merge_sort.o

merge_sort: merge_sort.o
	aarch64-linux-gnu-gcc -ggdb -static merge_sort.o -o merge_sort
