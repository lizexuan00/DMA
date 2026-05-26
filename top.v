`include "define.h"

module top (
	// Initiator 1
	input [`BUS_ADDR_WIDTH-1:0] addr0,
	input [`DATA_WIDTH-1:0] idata0,
	output [`DATA_WIDTH-1:0] odata0,
	input rw0_, input breq0_, output bgrt0_,
	input [`BUS_ADDR_WIDTH-1:0] dsaddr, // DMA source address
	input [`BUS_ADDR_WIDTH-1:0] ddaddr, // DMA destination address
	input [1:0] dmode, // DMA transfer mode
	input dreq_, // DMA request (*)
	output eop_, // DMA complete
	input reset_, input clk
);	

// Initiator 2
wire [`BUS_ADDR_WIDTH-1:0] addr1;
wire [`DATA_WIDTH-1:0] idata1;
wire [`DATA_WIDTH-1:0] odata1;
wire rw1_, breq1_, bgrt1_;

wire [`BUS_ADDR_WIDTH-1:0] addr;
wire [`DATA_WIDTH-1:0] idata, odata;
wire rw_;

assign odata0 = odata;
assign odata1 = odata;
assign addr   = (bgrt0_ ==`Enable_) ? addr0:addr1;// addr0 or addr1 depending on bgrt
assign idata  = (bgrt0_ ==`Enable_) ? idata0:idata1;// idata0 or idata1 depending on bgrt
assign rw_    = (bgrt0_ ==`Enable_) ? rw0_:rw1_;// rw0_ or rw1_ depending on bgrt

devices u0 (addr, idata, odata, rw_, reset_, clk);
busarb u1 (breq0_, breq1_, bgrt0_, bgrt1_, reset_, clk);
dmactr u2 (addr1, idata1, odata1, rw1_, breq1_, bgrt1_, 
			dsaddr, ddaddr, dmode, dreq_, eop_, reset_, clk);
endmodule
