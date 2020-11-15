`define Number_of_tests 10000

class tester;
	
	virtual alu_bfm bfm;

//------------------------------------------------------------------------------
// "New" auxiliary function
//------------------------------------------------------------------------------
	function new (virtual alu_bfm b);
		bfm = b;
	endfunction : new

//------------------------------------------------------------------------------
// Get random state function
//------------------------------------------------------------------------------

	protected function Current_state_t get_state();
		
		bit [2:0] random_state_code;
		random_state_code = $random;
		
		case (random_state_code)
			
			3'b000 : return AND_s;
			3'b001 : return OR_s;
			3'b010 : return ADD_s;
			3'b011 : return SUB_s;
			3'b100 : return ADD_s;
			3'b101 : return SUB_s;
			3'b110 : return RST_s;
			3'b111 : return RST_s;
			
		endcase
	endfunction : get_state

//------------------------------------------------------------------------------
// Get random data function
//------------------------------------------------------------------------------
	protected function [31:0] get_data();
		bit [3:0] zero_ones;
		zero_ones = $random;
		case (zero_ones)
			4'b0000 : return 32'h00000000;
			4'b0001 : return 32'h80000000;
			4'b1110 : return 32'h7FFFFFFF;
			4'b1111 : return 32'hFFFFFFFF;
			default : return $random;
		endcase
	endfunction : get_data

//------------------------------------------------------------------------------
// Execute task
//------------------------------------------------------------------------------
	task execute();
		bit [31:0] A;
		bit [31:0] B;
		operation_t set_op;
		Current_state_t current_state;
		
		bfm.rst_n = 1'b0;
		bfm.sin   = 1;
		@(negedge bfm.clk);
		@(negedge bfm.clk);
		bfm.rst_n = 1'b1;
		
		repeat (`Number_of_tests) begin : tester_main_loop
			@(negedge bfm.clk);
			current_state = get_state();
			A = get_data();
			B = get_data();
			case(current_state)
				RST_s: begin : rst_state
					@(negedge bfm.clk);
					bfm.rst_n = 1'b0;
					bfm.sin   = 1;
				end : rst_state
				default: begin : case_default
					@(negedge bfm.clk);
					bfm.rst_n = 1'b1;
					case(current_state)
						AND_s: set_op = AND;
						OR_s: set_op  = OR;
						ADD_s: set_op = ADD;
						SUB_s: set_op = SUB;
					endcase
					bfm.perform_operation(A,B,set_op);
				end
			endcase
		end : tester_main_loop
		
		if(bfm.error) 
			$display("========================= TEST FAILED =========================");
		else 
			$display("========================= TEST PASSED =========================");
		$finish;
	endtask : execute
	
endclass : tester
