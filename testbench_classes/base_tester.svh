`define Number_of_tests 10000

virtual class base_tester extends uvm_component;
	    `uvm_component_utils(base_tester)
	    
	virtual alu_bfm bfm;
	
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
       function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

    pure virtual function Current_state_t get_state();

    pure virtual function bit [31:0 ]get_data();

//------------------------------------------------------------------------------
// Execute task
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);
		bit [31:0] A;
		bit [31:0] B;
		operation_t set_op;
		Current_state_t current_state;
		
		phase.raise_objection(this);
		
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
		//$finish;
		phase.drop_objection(this);
	endtask : run_phase
	
endclass : base_tester
