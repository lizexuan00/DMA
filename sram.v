`include "define.h"

module sram (
	// Memory address
	input [`MEM_ADDR_WIDTH-1:0] addr,
	// Input data and output data
	input [`DATA_WIDTH-1:0] idata,
	output [`DATA_WIDTH-1:0] odata,
	// Control signals (chip select, read/write, and clock)
	input cs_, input rw_, input clk
);

reg [`DATA_WIDTH-1:0] mem [(1<<`MEM_ADDR_WIDTH)-1:0];

assign odata = (rw_ == `Read && cs_ ==`Enable_) ? mem[addr] : 0;

always @ (posedge clk)
	if (cs_ == `Enable_ && rw_ == `Write) 
			mem[addr] <= idata;

endmodule
