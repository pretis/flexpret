restart
put ispmfile ../../../tests/isa/build/emulator/flex_du.inst.mem -radix ascii
put dspmfile ../../../tests/isa/build/emulator/flex_du.data.mem -radix ascii
run all
restart
put ispmfile ../../../tests/isa/build/emulator/flex_wu.inst.mem -radix ascii
put dspmfile ../../../tests/isa/build/emulator/flex_wu.data.mem -radix ascii
run all
restart
put ispmfile ../../../tests/isa/build/emulator/flex_ie.inst.mem -radix ascii
put dspmfile ../../../tests/isa/build/emulator/flex_ie.data.mem -radix ascii
run all
restart
put ispmfile ../../../tests/isa/build/emulator/flex_ee.inst.mem -radix ascii
put dspmfile ../../../tests/isa/build/emulator/flex_ee.data.mem -radix ascii
run all
