//////////////////////////////////////////////////////////////////
///
/// Project Name: 	unknown_project
///
/// File Name: 		avalon_st_if.sv
///
//////////////////////////////////////////////////////////////////
///
/// Author: 		Yael Karisi
///
/// Date Created: 	19.3.2020
///
/// Company: 		----
///
//////////////////////////////////////////////////////////////////
///
/// Description: 	Defines Avalon Stream interface 
///
//////////////////////////////////////////////////////////////////

import general_pack::*;

interface avalon_st_if #(parameter DATA_WIDTH_IN_BYTES = 16);
	logic 	[(DATA_WIDTH_IN_BYTES*$bits(byte)) - 1 : 0] data;
	logic 												valid;
	logic 												rdy;
	logic 												sop;
	logic 												eop;
	logic 	[log2up_func(DATA_WIDTH_IN_BYTES) - 1 : 0] 	empty;

	modport slave 	(input data, input valid, output rdy, input sop, input eop, input empty);

	modport master 	(output data, output valid, input rdy, output sop, output eop, output empty);

	task CLEAR_MASTER();
		data 	= '0;
		valid 	= 1'b0;
		sop 	= 1'b0;
		eop 	= 1'b0;
		empty 	= 0;
	endtask : CLEAR_MASTER

	task CLEAR_SLAVE();
		rdy 	= 1'b1;
	endtask : CLEAR_SLAVE

endinterface