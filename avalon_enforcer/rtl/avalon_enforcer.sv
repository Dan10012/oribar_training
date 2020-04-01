//////////////////////////////////////////////////////////////////
///
/// Project Name: 	Avalon Enforcer 
///
/// File Name: 		avalon_anforcer.sv
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

module avalon_enforcer (
	input logic clk,    
	input logic rst, 
	avalon_st_if.slave		untrusted, 
	avalon_st_if.master		enforced,

	output logic	valid_out_of_packet,	//An indication that goes up when a valid signal was received outside a packet.  
	output logic	second_sop_indc			//An indication that goes up when a second sop goes up during a packet. 
	
);

//////////////////////////////////////////
//// Typedefs ////////////////////////////
//////////////////////////////////////////

typedef enum logic { 
		WAITING_MSG,
		SENDING_MSG
	}	sm_avalon_enforcer; 

//////////////////////////////////////////
//// Declarations ////////////////////////
//////////////////////////////////////////

sm_avalon_enforcer				current_state; 

always_ff @(posedge clk or negedge rst) begin : state_machine
	// If rst is low, cleans all the signals
	if(~rst) begin
		current_state <= WAITING_MSG;
	end else begin
		unique case (current_state) // state machine that determines whether the module is waiting for a message or sending it.   
			WAITING_MSG: begin
				// If a message has been received, change state to SENDING_MSG
				if (untrusted.sop & untrusted.valid & enforced.rdy & ~untrusted.eop) begin
					current_state 	<= SENDING_MSG; 
				end
			end
			SENDING_MSG: begin
				// If finished sending a message, change state to WAITING_MSG 
				if (untrusted.valid & enforced.rdy & untrusted.eop) begin
					current_state <= WAITING_MSG;
				end
			end	
		endcase
	end
end

always_comb begin : comb_logic_by_state
	// The signal values are determined based on the current state of the module
	unique case (current_state)
		WAITING_MSG: begin
			enforced.sop 			= untrusted.sop & untrusted.valid; 			//start of message if sop and valid were recieved at the same clk
			valid_out_of_packet		= ~untrusted.sop & untrusted.valid; 			//indication goes up if a valid is received not in a message
			enforced.valid 			= untrusted.valid & ~valid_out_of_packet;		//valid out is 1 as long as valid in is received during a message
			second_sop_indc 		= 1'b0; 
		end
		SENDING_MSG: begin
			second_sop_indc 		= untrusted.valid & untrusted.sop;				//indication goes up if a second sop is received in a message
			enforced.valid 			= untrusted.valid ;							//In this state the valid_out_of_packet indication is irrelevant
			enforced.sop			= 1'b0 ; 
			valid_out_of_packet		= 1'b0; 
		end	
	endcase
end

always_comb begin : siganl_value_assignments 
	// These signals are not based on the current state
	if (enforced.valid) begin
		enforced.data 	= untrusted.data ; 
		enforced.eop 	= untrusted.eop ; 
	end else begin
		enforced.data 	= 1'b0 ; 
		enforced.eop 	= 1'b0; 
	end
	if (enforced.eop) begin
		enforced.empty 	= untrusted.empty;
	end else begin
		enforced.empty 	= 0;
	end
end

endmodule

