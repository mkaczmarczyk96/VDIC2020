class coverage extends uvm_component;
	
	    `uvm_component_utils(coverage)
	    
	virtual alu_bfm bfm;

	bit [98:0] sin_data_cov;
	Current_state_t set_state;
	bit [31:0] A_cov;
	bit [31:0] B_cov;

//------------------------------------------------------------------------------
// Deserialize task
//------------------------------------------------------------------------------

	task deserialize();
		forever begin
			@(posedge bfm.deserialize_sin_done or negedge bfm.rst_n);
			sin_data_cov = bfm.sin_data;
			if(~bfm.rst_n)begin
				set_state = RST_s;
			end
			else begin
				B_cov = {sin_data_cov[96-:8],sin_data_cov[85-:8],sin_data_cov[74-:8],sin_data_cov[63-:8]};
				A_cov = {sin_data_cov[52-:8],sin_data_cov[41-:8],sin_data_cov[30-:8],sin_data_cov[19-:8]};

				case(operation_t'(sin_data_cov[7-:3]))
					ADD: set_state = ADD_s;
					SUB: set_state = SUB_s;
					OR: set_state  = OR_s;
					AND: set_state = AND_s;
				endcase
			end
		end
	endtask


//------------------------------------------------------------------------------
// COverage section - refactored
//------------------------------------------------------------------------------

	covergroup op_cov;

		option.name = "cg_op_cov";

		coverpoint set_state {
			// #A1 test all operations
			bins A1_single_op[] = {[AND_s : RST_s]};

			// #A2 test all operations after reset
			bins A2_rst_op[]   = (RST_s => [AND_s:SUB_s]);

			// #A3 test reset after all operations
			bins A3_op_rst[]   = ([AND_s:SUB_s] => RST_s);

			// #A4 Test two random operations after each other
			bins A4_op_op[]   = ([AND_s:RST_s]=>[AND_s:RST_s]);

			// #A5 test two same operations in row
			bins A5_two_op[]    = ([AND_s:RST_s] [* 2]);
		}

	endgroup

	covergroup zeros_ones_max_min_on_ops;

		option.name = "cg_zeros_ones_max_min_on_ops";

		all_ops : coverpoint set_state {
			ignore_bins null_ops = {RST_s};
		}

		a_leg: coverpoint A_cov {
			bins zeroes    = {'h00000000};
			bins positive = {['h01:'h7FFFFFFE]};
			bins negative = {['h80000001:'hFFFFFFFE]};
			bins ones     = {'hFFFFFFFF};
			bins max      = {'h7FFFFFFF};
			bins min      = {'h80000000};			
		}

		b_leg: coverpoint B_cov {
			bins zeroes    = {'h00000000};
			bins positive = {['h01:'h7FFFFFFE]};
			bins negative = {['h80000001:'hFFFFFFFE]};
			bins ones     = {'hFFFFFFFF};
			bins max      = {'h7FFFFFFF};
			bins min      = {'h80000000};
		}

		B_op_00_FF_min_max: cross a_leg, b_leg, all_ops {

			// #B1 simulate all zero input for all the operations

			bins B1_add_00 = binsof (all_ops) intersect {ADD_s} &&
			(binsof (a_leg.zeroes) || binsof (b_leg.zeroes));

			bins B1_and_00 = binsof (all_ops) intersect {AND_s} &&
			(binsof (a_leg.zeroes) || binsof (b_leg.zeroes));

			bins B1_or_00 = binsof (all_ops) intersect {OR_s} &&
			(binsof (a_leg.zeroes) || binsof (b_leg.zeroes));

			bins B1_sub_00 = binsof (all_ops) intersect {SUB_s} &&
			(binsof (a_leg.zeroes) || binsof (b_leg.zeroes));

			// #B2 simulate all one input for all the operations

			bins B2_add_FF = binsof (all_ops) intersect {ADD_s} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_and_FF = binsof (all_ops) intersect {AND_s} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_or_FF = binsof (all_ops) intersect {OR_s} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_sub_FF = binsof (all_ops) intersect {SUB_s} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B3_add_ovf = binsof (all_ops) intersect {ADD_s} &&
			(binsof (a_leg.max) && binsof (b_leg.positive));
			bins B4_sub_ovf = binsof (all_ops) intersect {SUB_s} &&
			(binsof (a_leg.positive) && binsof (b_leg.min));

			ignore_bins positive_only = binsof(a_leg.positive) && binsof(b_leg.positive);
			ignore_bins negative_only = binsof(a_leg.negative) && binsof(b_leg.negative);
			ignore_bins positive_negative = binsof(a_leg.positive) && binsof(b_leg.negative);
			ignore_bins negative_positive = binsof(a_leg.negative) && binsof(b_leg.positive);
		}

	endgroup
	
//------------------------------------------------------------------------------
// "New" auxiliary function
//------------------------------------------------------------------------------	

	function new (string name, uvm_component parent);
        	super.new(name, parent); 	 
			op_cov = new();
			zeros_ones_max_min_on_ops = new();
    	endfunction : new
    

        function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase
//------------------------------------------------------------------------------
// Execute task
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);
		fork
			deserialize;
			forever begin : sample_cov
				@(negedge bfm.deserialize_sin_done or posedge bfm.rst_n)
					op_cov.sample();
					zeros_ones_max_min_on_ops.sample();
			end : sample_cov
		join
	endtask:run_phase

endclass : coverage
