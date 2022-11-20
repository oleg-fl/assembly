all: memcmp

memcmp.o: memcmp.s
	arm-linux-gnueabihf-as --gdwarf-2 memcmp.s -o memcmp.o

memcmp: memcmp.o
	arm-linux-gnueabihf-gcc -ggdb -static memcmp.o -o memcmp
