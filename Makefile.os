# Makefile config
export LDLIBS   := 
export LDFLAGS  := 
export WFLAGS   := 
export CPPFLAGS := 
export CXXFLAGS := 
export CFLAGS   := 

.PHONY: all run run_cgdb info clean cleanall

all:
	$(MAKE) -f Makefile all

lib:
	$(MAKE) -f Makefile lib

run:
	$(MAKE) -f Makefile run

run_valgrind:
	$(MAKE) -f Makefile run_valgrind

run_cgdb:
	$(MAKE) -f Makefile run_cgdb

info:
	$(MAKE) -f Makefile info

clean:
	$(MAKE) -f Makefile clean

cleanall:
	$(MAKE) -f Makefile cleanall
