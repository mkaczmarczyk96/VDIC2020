module tester_module(alu_bfm bfm);
	import alu_pkg::*;


	function Current_state_t get_state();
		bit [3:0] state;
		state = $random;
		casex (state)
			4'h0, 4'h4, 4'h8, 4'hC : return AND_s;
			4'h1, 4'h5, 4'h9, 4'hD : return OR_s;
			4'h2, 4'h6, 4'hA, 4'hE : return ADD_s;
			4'h3, 4'h7, 4'hB : return SUB_s;
			4'hF : return RST_s;
		endcase
	endfunction : get_state

	function [31:0] get_data();
		bit [3:0] zero_ones;
		zero_ones = $random();
		if (zero_ones == 4'h0)
			return 32'h00000000;
		else if (zero_ones == 4'h1)
			return 32'h00000001;
		else if (zero_ones == 4'h2)
			return 32'h7FFFFFFF;
		else if (zero_ones == 4'h3)
			return 32'hFFFFFFFE;
		else if (zero_ones == 4'h4)
			return 32'h80000001;
		else if (zero_ones == 4'h5)
			return 32'h7FFFFFFE;
		else if (zero_ones == 4'h6)
			return 32'h80000000;
		else if (zero_ones == 4'h7)
			return 32'hFFFFFFFF;
		else
			return $random;
	endfunction : get_data

	initial begin
		bit [31:0] iA;
		bit [31:0] iB;
		operation_t op;
		Current_state_t Current_state;

		repeat (10000) begin
			Current_state = get_state();
			case(Current_state)
				AND_s: op = AND;
				OR_s: op  = OR;
				ADD_s: op = ADD;
				SUB_s: op = SUB;
				default: op = ADD;
			endcase
			iA = get_data();
			iB = get_data();
			bfm.perform_operation(iA, iB, Current_state, op);
		end
	end
endmodule : tester_module
