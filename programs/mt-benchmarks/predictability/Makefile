
build:
	../../../scripts/c/riscv-compile.sh 4 pr preditability.c

clean:
	../../../scripts/c/riscv-clean.sh

rebuild: clean build

run: 
	../../../emulator/fp-emu +ispm=pr.mem

c-b-run: rebuild run

PHONY: build clean rebuild run c-b-run