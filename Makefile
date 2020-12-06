# -- IMAGE --

.PHONY: load
load:
	image/load

.PHONY: burn
burn:
	image/burn

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

