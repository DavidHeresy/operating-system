# -- IMAGE --

.PHONY: load
load:
	image/load

.PHONY: burn
burn:
	image/burn


# -- VM --

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

.PHONY: info
info:
	vm/info

.PHONY: info
eject:
	vm/eject

