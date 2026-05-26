`include "define.h"
module addrdec (
	// Memory address
	input [`BUS_ADDR_WIDTH-1:0] addr,
	// Four chip select signals (active-low)
	output cs0_, output cs1_, output cs2_, output cs3_
);

assign cs0_ = ~(addr[9:8] == 2'b00);
assign cs1_ = ~(addr[9:8] == 2'b01);
assign cs2_ = ~(addr[9:8] == 2'b10);
assign cs3_ = ~(addr[9:8] == 2'b11);

endmodule
