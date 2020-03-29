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
	input logic clk,    
	input logic rst, 
	avalon_st_if.slave		untrusted, 
	avalon_st_if.master 	enforced,

	output logic 	valid_out_of_packet, //An indication that goes up when a valid signal was received outside a packet.  
	output logic 	wrong_valid 		 //An indication that goes up when a second sop goes up during a packet. 
	
);

//////////////////////////////////////////
//// Typedefs ////////////////////////////
//////////////////////////////////////////

typedef enum { 
		WAITING_MSG,
		SENDING_MSG
	} SM_avalon_enforcer; // state machine that determines whether the module is waiting for a message or sending it.   

//////////////////////////////////////////
//// Declarations ////////////////////////
//////////////////////////////////////////

logic							out_sop;
logic							out_vld;
SM_avalon_enforcer				current_state; 

always_ff @(posedge clk or negedge rst) begin
	// If rst is low, cleans all the signals
	if(~rst) begin
		current_state <= WAITING_MSG;
		untrusted.data 		= '0;
		untrusted.valid 	= 1'b0;
		untrusted.sop 		= 1'b0;
		untrusted.eop 		= 1'b0;
		untrusted.empty 	= 0;

		enforced.data 		= '0;
		enforced.valid 		= 1'b0;
		enforced.sop 		= 1'b0;
		enforced.eop 		= 1'b0;
		enforced.empty 		= 0;
		enforced.rdy 		= 1'b0;
	end else begin
		case (current_state)
			WAITING_MSG: begin
				//change state condition
				if (untrusted.sop & untrusted.valid & enforced.rdy & ~untrusted.eop) begin
					current_state 	<= SENDING_MSG;
				end
			end
			SENDING_MSG: begin
				//change state condition
				if (untrusted.valid & enforced.rdy & untrusted.eop) begin
					current_state <= WAITING_MSG;
				end
			end	
		endcase
	end
end

always_comb begin
	// The signal values are determined based on the current state of the module
	case (current_state)
			WAITING_MSG: begin
				out_sop 			<= untrusted.sop 	& untrusted.valid; 
				valid_out_of_packet <= ~untrusted.sop 	& untrusted.valid; 
				out_vld 			<= untrusted.valid 	& ~valid_out_of_packet;
				wrong_valid 		<= 1'b0; 
			end
			SENDING_MSG: begin
				wrong_valid 		<= untrusted.valid & untrusted.sop;
				out_vld 			<= untrusted.valid ;
				out_sop 			<= 1'b0 ; 
				valid_out_of_packet <= 1'b0; 
			end	
	endcase
	// These signals are not based on the current state
	if (out_vld) begin
		enforced.data 	= untrusted.data ; 
		enforced.eop 	= untrusted.eop ; 
	end
	if (enforced.eop) begin
		enforced.empty 	= untrusted.empty;
	end
end

endmodule