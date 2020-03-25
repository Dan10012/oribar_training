//////////////////////////////////////////////////////////////////
///
/// Project Name: 	Avalon Enforcer 
///
/// File Name: 		Avalon_Enforcer.sv
///
//////////////////////////////////////////////////////////////////
///
/// Author: 		Ori Barel
///
/// Date Created: 	25.3.2020
///
/// Company: 		----
///
//////////////////////////////////////////////////////////////////
///
/// Description: 	The module enforces the avalon_st protocol on an untrusted src 
///
//////////////////////////////////////////////////////////////////

module Avalon_Enforcer (
	input logic clk,    // Clock
	input logic rst,  // Asynchronous reset active low

	avalon_st_if.slave 		untrusted,
	avalon_st_if.master 	enforced,

	output logic 	valid_out_of_packet, 
	output logic 	wrong_valid
	
);

typedef enum {
		WAITING_MSG,
		SENDING_MSG
	} SM_avalon_enforcer

logic	 out_sop, out_vld, out_eop, out_empty;

SM_avalon_enforcer	 current_state; 

always_ff @(posedge clk or negedge rst) begin
	if(~rst) begin
		current_state <= WAITING_MSG;
	end else begin
		case (current_state)
			WAITING_MSG: begin
					
					if (untrusted.sop & untrusted.valid & untrusted.rdy & !untrusted.eop) begin
						current_state <= SENDING_MSG;
					end

					out_sop <= untrusted.sop & untrusted.valid; 
					valid_out_of_packet <= !untrusted.sop & untrusted.valid; 
					out_vld <= untrusted.valid & !valid_out_of_packet;
					wrong_valid <= '0'; 

			end
			SENDING_MSG: begin

					if (untrusted.valid & untrusted.rdy & untrusted.eop) begin
						current_state <= WAITING_MSG;
					end

					wrong_valid <= untrusted.valid & untrusted.sop;
					out_vld <= untrusted.valid ;
					out_sop <= '0' ; 
					valid_out_of_packet <= '0'; 

			end	
		endcase
	end
end

always_comb begin
	//resets all the data in the lanes
	// first_lane_out.CLEAR_MASTER();
	// second_lane_out.CLEAR_MASTER();

	if (out_vld) begin
		enforced.data 	= untrusted.data ; 
		enforced.eop 	= untrusted.eop ; 
	end
	if (enforced.eop) begin
		enforced.empty 	= untrusted.empty;
	end
end

endmodule