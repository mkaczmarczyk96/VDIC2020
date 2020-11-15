
module top;
	import alu_pkg::*;


// DUT instantiation
//--------------------------------------------------------------------------------------------
	mtm_Alu u_mtm_Alu (.clk (bfm.clk),.rst_n(bfm.rst_n),.sin (bfm.sin), .sout (bfm.sout));
//--------------------------------------------------------------------------------------------
	
	alu_bfm bfm();
	
	testbench testbench_i;

	initial begin
		testbench_i = new(bfm);
		testbench_i.execute();
	end

endmodule : top
