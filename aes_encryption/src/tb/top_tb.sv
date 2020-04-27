
`ifndef __TOP_TB
`define __TOP_TB

module top_tb ();
	
  	import uvm_pkg::*;

    /*------------------------------------------------------------------------------
    -- Local Signals.
    ------------------------------------------------------------------------------*/
    bit     clk = 1'b0;
  	bit			rst;
    localparam int DATA_WIDTH_IN_BYTES = 4;

    /*------------------------------------------------------------------------------
    -- Interfaces.
    ------------------------------------------------------------------------------*/
	avalon_st_if #(DATA_WIDTH_IN_BYTES) msg_in(.clk(clk));
	avalon_st_if #(DATA_WIDTH_IN_BYTES) msg_out(.clk(clk));
  logic enable;

    /*------------------------------------------------------------------------------
    -- Module declaration.
    ------------------------------------------------------------------------------*/

    enabled_avalon_st_connection enabled_avalon_st_connection_inst (
      .msg_in(msg_in),
      .msg_out(msg_out),
      .enable(enable)
      );
  	
    /*------------------------------------------------------------------------------
    -- Clock.
    ------------------------------------------------------------------------------*/
    always begin
        #5ns clk = ~clk;
    end



    /*------------------------------------------------------------------------------
    -- Run Test.
    ------------------------------------------------------------------------------*/
    initial begin
      // required in order to open EPWave
	  //$dumpfile("dump.vcd");
      //$dumpvars(0,top_tb);
      rst = 1'b1;
      enable = 1'b0;
      msg_in.data = '1;
      msg_in.sop = 1'b1;
      msg_in.eop = 1'b1;
      msg_in.empty = '0;
      msg_in.valid = 1'b1;
      msg_out.rdy = 1'b1;

      for (int i = 0; i < 3; i++) begin
        @(posedge clk);
      end

      enable = 1'b1;

      for (int i = 0; i < 3; i++) begin
        @(posedge clk);
      end

      enable = 1'b0;

      $finish;

    end
endmodule

`endif // __TOP_TB