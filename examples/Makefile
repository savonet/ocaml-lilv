SOURCES = test.ml
RESULT = test
INCDIRS = ../src
LIBS = lilv
PACKS = ctypes.foreign

all: dnc
	# valgrind --leak-check=full ./test
	./test

include OCamlMakefile
