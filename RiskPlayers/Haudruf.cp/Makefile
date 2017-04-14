ARCHES = -arch m68k -arch hppa -arch sparc -arch i386

.SUFFIXES: .m .o .c .psw

.m.o:
	cc -O -g -Wall $(ARCHES) -c $*.m -o $*.o

Haudruf.o: Haudruf.m

all::
	$(MAKE) Haudruf.o
