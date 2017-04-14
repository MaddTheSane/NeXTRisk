ARCHES = -arch m68k -arch hppa -arch sparc -arch i386

.SUFFIXES: .m .o .c .psw

.m.o:
	cc -O -g -Wall $(ARCHES) -c $*.m -o $*.o

Block.o: Block.m Block.h ../Coop.cp/Coop.o

all::
	$(MAKE) Block.o
