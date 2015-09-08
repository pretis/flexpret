restart
put ispmfile ../../../tests/isa/build/emulator/mul.inst.mem -radix ascii
put dspmfile ../../../tests/isa/build/emulator/mul.data.mem -radix ascii
run all
restart
put ispmfile ../../../tests/isa/build/emulator/mulh.inst.mem -radix ascii
put dspmfile ../../../tests/isa/build/emulator/mulh.data.mem -radix ascii
run all
restart
put ispmfile ../../../tests/isa/build/emulator/mulhsu.inst.mem -radix ascii
put dspmfile ../../../tests/isa/build/emulator/mulhsu.data.mem -radix ascii
run all
restart
put ispmfile ../../../tests/isa/build/emulator/mulhu.inst.mem -radix ascii
put dspmfile ../../../tests/isa/build/emulator/mulhu.data.mem -radix ascii
run all
