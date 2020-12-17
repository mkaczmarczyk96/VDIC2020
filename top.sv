module top;
	import uvm_pkg::*;
	import alu_pkg::*;
	`include "uvm_macros.svh"


	alu_bfm class_bfm();
	mtm_Alu class_mtm_Alu (.clk (class_bfm.clk),.rst_n(class_bfm.rst_n),.sin (class_bfm.sin),.sout (class_bfm.sout));



	alu_bfm module_bfm();
	mtm_Alu module_mtm_Alu (.clk (module_bfm.clk),.rst_n(module_bfm.rst_n),.sin (module_bfm.sin),.sout (module_bfm.sout));


	tester_module stim_module(module_bfm);

	initial begin
		uvm_config_db #(virtual alu_bfm)::set(null, "*", "class_bfm", class_bfm);
		uvm_config_db #(virtual alu_bfm)::set(null, "*", "module_bfm", module_bfm);
		run_test("dual_test");
	end

endmodule : top
