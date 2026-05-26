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

	// initialize all signals to known state before reset
	addr0  = 0;
	idata0 = 0;
	rw0_   = `Read;
	breq0_ = `Disable_;
	dreq_  = `Disable_;
	dsaddr = 0;
	ddaddr = 0;
	dmode  = 2'b00;

	// 1. Reset
	reset_ = `Enable_;
	repeat(3) @(posedge clk);
	reset_ = `Disable_;
	@(posedge clk);

	// 2. Memory write by CPU (initiator 1): write 0x99 to 0x150
	// bgrt0_ is already Enable_ after reset (busarb starts in BGRT0)
	breq0_ = `Enable_;
	@(posedge clk);
	addr0  = 10'h150;
	idata0 = 8'h99;
	rw0_   = `Write;
	@(posedge clk);        // SRAM writes at this edge

	// 3. Memory read by CPU (initiator 1): verify write succeeded
	rw0_   = `Read;
	#1;                    // combinational propagation
	$display("Read  0x150 = 0x%h  (expect 0x99)", odata0);
	breq0_ = `Disable_;
	@(posedge clk);

	// 4. Data transfer by DMAC (initiator 2): burst M->M, 0x150-0x153 -> 0x160-0x163
	// breq0_ must be de-asserted so DMAC can win bus arbitration
	dsaddr = 10'h150;
	ddaddr = 10'h160;
	dmode  = 2'b01;        // burst memory-to-memory
	dreq_  = `Enable_;
	@(posedge clk);        // DMAC sees dreq_, asserts breq_
	dreq_  = `Disable_;    // de-assert immediately to prevent re-trigger
	@(negedge eop_);       // wait for DMA transfer complete (eop_ goes low)
	@(posedge clk);

	// 5. Memory read by CPU (initiator 1): verify DMA transfer to 0x160
	breq0_ = `Enable_;
	@(negedge bgrt0_);     // wait until CPU gets bus grant back
	addr0  = 10'h160;
	rw0_   = `Read;
	#1;                    // combinational propagation
	$display("Read  0x160 = 0x%h  (expect 0x99)", odata0);
	breq0_ = `Disable_;
	repeat(2) @(posedge clk);

	$finish;
end

endmodule
