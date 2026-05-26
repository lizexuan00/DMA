`include "define.h"

module dmactr (
	// Signals between DMAC and devices
	output reg [`BUS_ADDR_WIDTH-1:0] addr,	// Memory or I/O address
	output reg [`DATA_WIDTH-1:0] odata,	// Write data
	input [`DATA_WIDTH-1:0] idata,		// Read data
	output reg rw_,				/ß/ Read/write signal
	// Signals between DMAC and bus arbiter
	output reg breq_,			// Bus request
	input bgrt_,				// Bus grant
	input [`BUS_ADDR_WIDTH-1:0] dsaddr,// DMA source address
	input [`BUS_ADDR_WIDTH-1:0] ddaddr,// DMA destination address
	input [1:0] dmode, // DMA transfer mode
	input dreq_, // DMA request (*)
	output reg eop_, // DMA complete
	input reset_, input clk
);

// Not implemented yet

reg [1:0] state;

always @ (posedge clk)
	if (reset_ == `Enable_) begin
		eop_ <= `Disable_;
		dreq_ <= `Disable_;
		bgrt_ <= `Disable_;
		rw_ <= `Write;
		addr <= 0;
	end else begin
		case (state)
		`WAIT: begin
			if (dreq_ == `Enable_) begin
				breq_ <= `Enable_;
				state <= `READ1;
			end
		end
		`READ1: begin
			if (bgrt_ == `Enable_) beign
				addr <= dsaddr;
				rw_	<= `Read;
				state <= WRITE1;
			end
		end
		`WRITE1: begin
			addr <= ddaddr;
			rw_ <= `Write;
			odata <= idata;
			state <= `DONE;
		end
		`DONE: begin
			eop_ <= `Enable_;
			breq_ <= `Disable_;
			state <= `WAIT;
		end
		endcase
	end

endmodule
