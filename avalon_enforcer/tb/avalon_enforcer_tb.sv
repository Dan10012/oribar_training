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
module avalon_enforcer_tb ();
	
	//sets the bus width for data
	localparam int DATA_WIDTH_IN_BYTES = 16;

	logic clk; 
	logic rst; 
	//creates lanes using avalon_st interface 
	avalon_st_if #(.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES)) untrusted();
	avalon_st_if #(.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES)) enforced(); 

	logic 	valid_out_of_packet;
	logic 	second_sop_indc;

	//instantiates the items based on the avalon_st interface
	avalon_enforcer avalon_enforcer_inst
	(
		.clk(clk), 
		.rst(rst),
		.untrusted(untrusted.slave),
		.enforced(enforced.master),
		.valid_out_of_packet(valid_out_of_packet),
		.second_sop_indc(second_sop_indc) 
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

		enforced.rdy 		= 1'b0;

		#20;
		rst 				= 1'b1;

		//Basic TB, makes sure everything works correctly 
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
		untrusted.eop 		= 1'b0;
		untrusted.empty 	= 0;
		enforced.rdy 		= 1'b0;

		#15;
		// Test a very short message, when eop and sop arrive at the same time
		@(posedge clk);
		enforced.rdy 		= 1'b1;
		untrusted.valid 	= 1'b1;
		untrusted.data 		= {DATA_WIDTH_IN_BYTES{8'd34}};
		untrusted.sop 		= 1'b1;
		untrusted.eop		= '1;
		untrusted.empty		= 1; 
		@(posedge clk);
		untrusted.data 		= '0;
		untrusted.valid 	= 1'b0;
		untrusted.sop 		= 1'b0;
		untrusted.eop 		= 1'b0;
		untrusted.empty 	= 0;
		enforced.rdy 		= 1'b0;

		#15
		//Checks Valid_out_of_packet 
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
		untrusted.eop 		= 1'b0;
		untrusted.empty 	= 0;
		@(posedge clk);
		untrusted.valid 	= 1'b1;
		@(posedge clk);
		untrusted.valid 	= 1'b0;
		enforced.rdy 		= 1'b0;

		#15
		//Checks second sop indicator
		@(posedge clk);
		enforced.rdy 		= 1'b1;
		untrusted.valid 	= 1'b1;
		untrusted.data 		= {DATA_WIDTH_IN_BYTES{8'd34}};
		untrusted.sop 		= 1'b1;
		@(posedge clk);
		untrusted.sop 		= 1'b0;
		@(posedge clk);
		untrusted.sop 		= 1'b1;
		@(posedge clk);
		untrusted.sop 		= 1'b0;
		@(posedge clk);
		untrusted.eop		= '1;
		untrusted.empty		= 1; 
		@(posedge clk);

		untrusted.data 		= '0;
		untrusted.valid 	= 1'b0;
		untrusted.eop 		= 1'b0;
		untrusted.empty 	= 0;
		enforced.rdy 		= 1'b0;		

		#15
		//Tests a case when the message isn't contiguous, valid goes down in the middle of the message
		@(posedge clk);
		enforced.rdy 		= 1'b1;
		untrusted.valid 	= 1'b1;
		untrusted.data 		= {DATA_WIDTH_IN_BYTES{8'd34}};
		untrusted.sop 		= 1'b1;
		@(posedge clk);
		untrusted.sop 		= 1'b0;
		untrusted.valid 	= 1'b0;
		@(posedge clk);
		@(posedge clk);
		untrusted.valid 	= 1'b1;
		untrusted.eop		= '1;
		untrusted.empty		= 1; 
		@(posedge clk);

		untrusted.data 		= '0;
		untrusted.valid 	= 1'b0;
		untrusted.eop 		= 1'b0;
		untrusted.empty 	= 0;
		enforced.rdy 		= 1'b0;

		#15
		//Tests a case when empty doesn't go up with eop 
		@(posedge clk);
		enforced.rdy 		= 1'b1;
		untrusted.valid 	= 1'b1;
		untrusted.data 		= {DATA_WIDTH_IN_BYTES{8'd34}};
		untrusted.sop 		= 1'b1;
		@(posedge clk);
		untrusted.sop 		= 1'b0;
		@(posedge clk);
		untrusted.empty		= 1; 
		@(posedge clk);
		untrusted.eop		= '1;
		@(posedge clk);

		untrusted.data 		= '0;
		untrusted.valid 	= 1'b0;
		untrusted.eop 		= 1'b0;
		untrusted.empty 	= 0;
		enforced.rdy 		= 1'b0;

		$finish();

	end

endmodule