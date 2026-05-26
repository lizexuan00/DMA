`include "define.h"

module busarb (
	// Bus request/grant for initiators 1 and 2
	input breq0_, input breq1_, output bgrt0_, output bgrt1_,
	input reset_, input clk
);

reg state;

assign bgrt0_ = (state == `BGRT0) ? `Enable_ : `Disable_;
assign bgrt1_ = (state == `BGRT1) ? `Enable_ : `Disable_;

always @ (posedge clk)
	if (reset_ == `Enable_) begin
		state <= `BGRT0;
		// State register should be initialized
	end else begin
		case (state)
		`BGRT0: if (breq0_ == `Disable_ && breq1_ == `Enable_)
				state <= `BGRT1;
		`BGRT1: if (breq1_ == `Disable_ && breq0_ == `Enable_)
				state <= `BGRT0;
		endcase
	end

endmodule
