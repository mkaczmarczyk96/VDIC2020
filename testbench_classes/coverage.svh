class coverage extends uvm_subscriber #(command_s);
	`uvm_component_utils(coverage)


//	bit [98:0] sin_data_cov;

	Current_state_t set_state;
	bit [31:0] A_cov;
	bit [31:0] B_cov;

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

//------------------------------------------------------------------------------
// Write function
//------------------------------------------------------------------------------

    	function void write(command_s t);
	    	A_cov = t.A;
        	B_cov = t.B;
        	set_state = t.Current_state;
        	op_cov.sample();
        	zeros_ones_max_min_on_ops.sample();
    	endfunction : write

endclass : coverage
