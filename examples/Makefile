DIRS = $(wildcard */)

all test:
	for d in $(DIRS); do $(MAKE) -C $$d $@ || exit 1; done
