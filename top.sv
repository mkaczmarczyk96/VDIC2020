
module top;
	import alu_pkg::*;
	import uvm_pkg::*;
	`include "uvm_macros.svh"


// DUT instantiation
//--------------------------------------------------------------------------------------------
	mtm_Alu u_mtm_Alu (.clk (bfm.clk),.rst_n(bfm.rst_n),.sin (bfm.sin), .sout (bfm.sout));
//--------------------------------------------------------------------------------------------
	
	alu_bfm bfm();
	
	initial begin
   		uvm_config_db #(virtual alu_bfm)::set(null, "*", "bfm", bfm);
   		run_test();
	end

endmodule : top
