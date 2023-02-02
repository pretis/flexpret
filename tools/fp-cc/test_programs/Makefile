
build:
	../../../scripts/c/riscv-compile.sh 1 test test.c

clean:
	../../../scripts/c/riscv-clean.sh

rebuild: clean build

run: 
	../../../emulator/fp-emu +ispm=test.mem

c-b-run: rebuild run

PHONY: build clean rebuild run c-b-run