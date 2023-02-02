
build:
	../../../scripts/c/riscv-compile.sh 5 mm matrix_multiply_stc_thr.c

clean:
	../../../scripts/c/riscv-clean.sh

rebuild: clean build

run: 
	../../../emulator/fp-emu +ispm=mm.mem

c-b-run: rebuild run

PHONY: build clean rebuild run c-b-run