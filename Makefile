test:	test.v top.v busarb.v dmactr.v devices.v addrdec.v sram.v timer.v
	iverilog test.v top.v busarb.v dmactr.v devices.v addrdec.v sram.v timer.v
	vvp a.out

clean:
	rm -f a.out dump.vcd
