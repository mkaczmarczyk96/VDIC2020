class coverage extends uvm_subscriber #(sequence_item);
    `uvm_component_utils(coverage)

	 state_t op_state;
	bit [31:0] A_cov;
	bit [31:0] B_cov;

	covergroup op_cov;

		option.name = "cg_op_cov";

		coverpoint op_state {
			// #A1 test all operations
			bins A1_single_op[] = {[and_state : rst_state]};

			// #A2 test all operations after reset
			bins A2_rst_opn[]   = (rst_state => [and_state:sub_state]);

			// #A3 test reset after all operations
			bins A3_opn_rst[]   = ([and_state:sub_state] => rst_state);

			// #A4 Test each op after each
			bins A4_opn_opn[]   = ([and_state:rst_state]=>[and_state:rst_state]);

			// #A5 two operations in row
			bins A5_twoops[]    = ([and_state:rst_state] [* 2]);
		}

	endgroup

	covergroup zeros_ones_max_min_on_ops;

		option.name = "cg_zeros_ones_max_min_on_ops";

		all_ops : coverpoint op_state {
			ignore_bins null_ops = {rst_state};
		}

		a_leg: coverpoint A_cov {
			bins zeros    = {'h00000000};
			bins max      = {'h7FFFFFFF};
			bins min      = {'h80000000};
			bins positive = {['h01:'h7FFFFFFE]};
			bins negative = {['h80000001:'hFFFFFFFE]};
			bins ones     = {'hFFFFFFFF};
		}

		b_leg: coverpoint B_cov {
			bins zeros    = {'h00000000};
			bins max      = {'h7FFFFFFF};
			bins min      = {'h80000000};
			bins positive = {['h01:'h7FFFFFFE]};
			bins negative = {['h80000001:'hFFFFFFFE]};
			bins ones     = {'hFFFFFFFF};
		}

		B_op_00_FF_min_max: cross a_leg, b_leg, all_ops {

			// #B1 simulate all zero input for all the operations

			bins B1_add_00                = binsof (all_ops) intersect {add_state} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_and_00                = binsof (all_ops) intersect {and_state} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_or_00                 = binsof (all_ops) intersect {or_state} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_sub_00                = binsof (all_ops) intersect {sub_state} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			// #B2 simulate all one input for all the operations

			bins B2_add_FF                = binsof (all_ops) intersect {add_state} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_and_FF                = binsof (all_ops) intersect {and_state} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_or_FF                 = binsof (all_ops) intersect {or_state} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_sub_FF                = binsof (all_ops) intersect {sub_state} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B3_add_ovf               = binsof (all_ops) intersect {add_state} &&
			(binsof (a_leg.max) && binsof (b_leg.positive));
			bins B4_sub_ovf               = binsof (all_ops) intersect {sub_state} &&
			(binsof (a_leg.positive) && binsof (b_leg.min));

			ignore_bins positive_only     =
			binsof(a_leg.positive) && binsof(b_leg.positive);
			ignore_bins negative_only     =
			binsof(a_leg.negative) && binsof(b_leg.negative);
			ignore_bins positive_negative =
			binsof(a_leg.positive) && binsof(b_leg.negative);
			ignore_bins negative_positive =
			binsof(a_leg.negative) && binsof(b_leg.positive);
		}

	endgroup

    function new (string name, uvm_component parent);
        super.new(name, parent);
		op_cov              = new();
		zeros_ones_max_min_on_ops = new();
    endfunction : new
	
    function void write(sequence_item t);
	A_cov      = t.A;
        B_cov      = t.B;
        op_state   = t.state;
        op_cov.sample();
        zeros_ones_max_min_on_ops.sample();
    endfunction : write

endclass : coverage
