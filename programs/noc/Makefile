build:
	riscv_compile.sh core0 core0.c
	riscv_compile.sh core1 core1.c
	riscv_compile.sh core2 core2.c
	riscv_compile.sh core3 core3.c

clean:
	riscv_clean.sh


rebuild: clean build

PHONY: build clean rebuild