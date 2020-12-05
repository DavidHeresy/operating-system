# -- ISO IMAGE --

download:
	wget \
		-c https://iso.artixlinux.org/iso/artix-base-runit-20201128-x86_64.iso \
		-O image.iso


# -- VIRTUAL MACHINE --

.PHONY: build
build:
	vm/build

.PHONY: clean
clean:
	vm/clean

.PHONY: start
start:
	vm/start

.PHONY: stop
stop:
	vm/stop

