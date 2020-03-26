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
module Avalon_Enforcer_TB ();
	
	//sets the bus width for data
	localparam int DATA_WIDTH_IN_BYTES = 16;

	logic clk; 
	logic rst; 
	//creates lanes using avalon_st interface 
	avalon_st_if #(.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES)) untrusted();
	avalon_st_if #(.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES)) enforced(); 

	logic 	valid_out_of_packet;
	logic 	wrong_valid;

	//instantiates the items based on the avalon_st interface
	Avalon_Enforcer avalon_enforcer_inst
	(
		.clk(clk), 
		.rst(rst),
		.untrusted(untrusted.slave),
		.enforced(enforced.master),
		.valid_out_of_packet(valid_out_of_packet),
		.wrong_valid(wrong_valid) 
	); 
	
	always #5 clk = ~clk;

	initial begin 
		//clean the signal values in both lanes
		clk 				= 1'b0;
		rst 				= 1'b0;

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

		valid_out_of_packet = 1'b0;
		wrong_valid 		= 1'b0;

		#20;
		rst 				= 1'b1;

		//input signal values to the signals
		@(posedge clk);
		enforced.rdy 		= 1'b1;
		untrusted.valid 	= 1'b1;
		untrusted.data 		= {DATA_WIDTH_IN_BYTES{8'd34}};
		untrusted.sop 		= 1'b1;
		@(posedge clk);
		untrusted.sop 		= 1'b0;
		@(posedge clk);
		untrusted.eop		= '1;
		untrusted.empty		= 1; 
		@(posedge clk);

		untrusted.data 		= '0;
		untrusted.valid 	= 1'b0;
		untrusted.sop 		= 1'b0;
		untrusted.eop 		= 1'b0;
		untrusted.empty 	= 0;

		#15;

		$finish();

	end

endmodule