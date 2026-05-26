`timescale 1ns/10ps
`include "define.h"

module test ();

reg [`BUS_ADDR_WIDTH-1:0] addr0;
reg [`DATA_WIDTH-1:0] idata0;
wire [`DATA_WIDTH-1:0] odata0;
reg rw0_, breq0_, dreq_;
wire bgrt0_, eop_;
reg [`BUS_ADDR_WIDTH-1:0] dsaddr, ddaddr;
reg [1:0] dmode;
reg reset_, clk;

top u0 (addr0, idata0, odata0, rw0_, breq0_, bgrt0_, dsaddr, ddaddr, dmode, dreq_, eop_, reset_, clk);

always begin
	clk <= 1; #1;
	clk <= 0; #1;
end

initial begin
	#1;
	$dumpfile("dump.vcd");
	$dumpvars(0, test.u0);
	// 1. Reset
	...
	// 2. Memory write by CPU (initiator 1)
	...
	// 3. Memory read by CPU (initiator 1)
	...
	// 4. Data transfer by DMAC (initiator 2)
	...
	// 5. Memory read by CPU (initiator 1)
	...
	$finish;
end

endmodule
