.PHONY: build install uninstall clean doc test all

build:
	@dune build @default

install:
	@dune install

uninstall:
	@dune uninstall

clean:
	@dune clean

doc:
	@dune build @doc

test:
	@dune build @runtest
	$(MAKE) -C examples $@

all: build test doc
