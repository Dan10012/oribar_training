module aes_sm (
	input logic clk,    
	input logic rst, 
	avalon_st_if.slave		msg_in, 
	avalon_st_if.master		msg_out,
	avalon_st_if.slave		sync_and_key_in, 

	output logic	same_sync,
	output logic	second_sop_indc			//An indication that goes up when a second sop goes up during a packet. 
	); 
	typedef enum logic { 
		WAIT_FOR_SYNC_AND_KEY,
		MAIN_ROUNDS,
		FINAL_ROUND,
		ENCRYPT_WORD
	}	sm_avalon_enforcer; 

	sm_avalon_enforcer				current_state; 
	int 							word_cntr, round_cntr;
	byte   [7:0]					msg_sync[16];  
	byte   [7:0]					msg_key[16];  
	byte   [7:0]					state_data[16];  

	always_ff @(posedge clk or negedge rst) begin : state_machine
		// If rst is low, cleans all the signals
		if(~rst) begin
			current_state <= WAIT_FOR_SYNC_AND_KEY;
		end else begin
			unique case (current_state) // state machine that determines whether the module is waiting for a message or sending it.   
				WAIT_FOR_SYNC_AND_KEY: begin
					word_cntr <= 0;
					round_cntr <= 0;
					msg_sync <= Sync_and_key_in.sync;
					msg_key <= Sync_and_key_in.key;

					if (sync_and_key_in.valid & sync_and_key_in.rdy & ~same_sync ) begin
						current_state 	<= MAIN_ROUNDS; 
					end
				end
				MAIN_ROUNDS: begin
					round_cntr + = 1;      
					if round_cntr = 0 begin :
        				if  word_cntr = 0              
        					state_data <= msg_sync ^ msg_key ;   
       					else?              
       						state_data <= (msg_sync ++) ^ msg_key;   
       						round key  <=  key_generator(msg_key);
       					end
       				else?    
       					state_data <= main_round(state_data, round_key);  
       					round_key  <=  key_generator(round_key); 
       				end
       				if (round_cntr = 10) begin
						current_state 	<= FINAL_ROUND; 
					end
				end	
				FINAL_ROUND: begin
					word_cntr += 1;
					?encrypted_sync <= final_round(state_data, round_key)
					current_state 	<= ENCRYPT_WORD; 
				end
				ENCRYPT_WORD: begin
					if (msg_in.valid & msg_in.eop & msg_in_rdy) begin
						current_state 	<= WAIT_FOR_SYNC_AND_KEY; 
					end 	
					else if (msg_in.valid & ~msg_in.eop & msg_in.rdy) begin 
						current_state 	<= MAIN_ROUNDS; 
					end

			endcase
		end
	end

	always_comb begin : comb_logic_by_state
	// The signal values are determined based on the current state of the module
	unique case (current_state)
		WAIT_FOR_SYNC_AND_KEY: begin
			sync_and_key_in.rdy 		= 1'b1;
			if (msg_sync = sync_and_key_in.sync) begin
				same_sync = 1'b1; 
			end

			sync_and_key_rdy	= 1'b1 ;  
			msg_out.sop 		= 1'b0 ;
			msg_out.eop			= 1'b0 ;
			msg_out.data		= 1'b0 ;
			second_sop 			= 1'b0 ; 
			sop_received 		= 1'b0 ;
			state_data 			= 0 ; 
			
		end
		MAIN_ROUNDS: begin
			sync_and_key_rdy	= 1'b0 ;  
			msg_out.sop 		= 1'b0 ;
			msg_out.eop			= 1'b0 ;
			msg_out.data		= 1'b0 ;
			second_sop 			= 1'b0 ;
			sop_received 		= 1'b0 ;
			state_data 			= 0 ;
			same_sync = 1'b0;  
		end
		FINAL_ROUND: begin
			sync_and_key_rdy	= 1'b0 ;  
			msg_out.sop 		= 1'b0 ;
			msg_out.eop			= 1'b0 ;
			msg_out.data		= 1'b0 ;
			second_sop 			= 1'b0 ;
			sop_received 		= 1'b0 ;
			state_data 			= 0 ; 
			same_sync = 1'b0; 
		end
		ENCRYPT_WORD: begin
			msg_in_rdy = msg_out_rdy; 
			if (msg_in_vld & word_cntr > 1 & msg_in_sop) begin:
				second_sop = 1'b1;   
			end 
			msg_out_data = msg_in_data XOR encrypted_sync; 
			msg_out_vld = msg_in_vld ; 
			msg_out_sop = msg_in_sop & msg_in_vld & ~second_sop; 
			msg_out_eop = msg_in_eop & msg_in_vld;
			
			sync_and_key_rdy = 1'b0;
		    same_sync = 1'b0; 
		end	
	endcase
end