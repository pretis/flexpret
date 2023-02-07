build:
	riscv-compile.sh 1 core0 core0.c
	riscv-compile.sh 1 core1 core1.c
	riscv-compile.sh 1 core2 core2.c
	riscv-compile.sh 1 core3 core3.c

clean:
	riscv-clean.sh


rebuild: clean build

PHONY: build clean rebuild