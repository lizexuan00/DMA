`include "define.h"

module dmactr (
	// Signals between DMAC and devices
	output reg [`BUS_ADDR_WIDTH-1:0] addr,	// Memory or I/O address
	output reg [`DATA_WIDTH-1:0] odata,	// Write data
	input [`DATA_WIDTH-1:0] idata,		// Read data
	output reg rw_,				// Read/write signal
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

localparam BURST_SIZE = 4;

reg [1:0] state;
reg [1:0] count;                        // word counter for burst
reg [`BUS_ADDR_WIDTH-1:0] src, dst;     // current src/dst addresses

always @ (posedge clk)
	if (reset_ == `Enable_) begin
		eop_  <= `Disable_;
		breq_ <= `Disable_;
		rw_   <= `Write;
		odata <= 0;
		addr  <= 0;
		count <= 0;
		src   <= 0;
		dst   <= 0;
		state <= `WAIT;
	end else begin
		case (state)
		`WAIT: begin
			if (dreq_ == `Enable_) begin
				breq_ <= `Enable_;
				src   <= dsaddr;   // latch addresses at request time
				dst   <= ddaddr;
				count <= 0;
				state <= `READ1;
			end
			eop_ <= `Disable_;
		end
		`READ1: begin
			if (bgrt_ == `Enable_) begin
				addr  <= src;
				rw_   <= `Read;
				state <= `WRITE1;
			end
		end
		`WRITE1: begin
			addr  <= dst;
			rw_   <= `Write;
			odata <= idata;
			if (dmode == 2'b00 || count == BURST_SIZE - 1) begin
				// single mode, or last word of burst
				state <= `DONE;
			end else begin
				// increment addresses for next burst word
				if (dmode == 2'b01 || dmode == 2'b10) src <= src + 1;
				if (dmode == 2'b01 || dmode == 2'b11) dst <= dst + 1;
				count <= count + 1;
				state <= `READ1;
			end
		end
		`DONE: begin
			eop_  <= `Enable_;
			breq_ <= `Disable_;
			state <= `WAIT;
		end
		endcase
	end

endmodule
