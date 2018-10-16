.SUFFIXES: .m .o .c .psw

.m.o:
	cc -O -g -Wall -c $*.m -o $*.o

all:	Strat.o

Strat.o:	PlayerCode.o SortedList.o
		ld -r SortedList.o PlayerCode.o -o Strat.o

PlayerCode.o:	PlayerCode.h PlayerCode.m
SortedList.o:	SortedList.h SortedList.m

clean:
	rm -f *.o

