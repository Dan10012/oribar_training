module enabled_avalon_st_connection (
	avalon_st_if.slave msg_in,
	avalon_st_if.master msg_out,
	
	input logic enable
);

always_comb begin
	if (enable) begin
		msg_out.data 	= msg_in.data;
        msg_out.sop 	= msg_in.sop;
        msg_out.eop 	= msg_in.eop;
        msg_out.empty 	= msg_in.empty;
        msg_out.valid 	= msg_in.valid;
        msg_in.rdy 		= msg_out.rdy;
	end else begin
		msg_out.data 	= '0;
        msg_out.sop 	= 1'b0;
        msg_out.eop 	= 1'b0;
        msg_out.empty 	= '0;
        msg_out.valid 	= 1'b0;
        msg_in.rdy 		= 1'b0;
	end
end

endmodule