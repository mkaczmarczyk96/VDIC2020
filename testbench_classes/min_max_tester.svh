class min_max_tester extends random_tester;

    `uvm_component_utils(min_max_tester)

	function bit [31:0] get_data();
		bit [3:0] zero_ones;
		zero_ones = $random;
		case (zero_ones)
			4'b0000 : return 32'h00000000;
			4'b0001 : return 32'h80000000;
			4'b1110 : return 32'h7FFFFFFF;
			4'b1111 : return 32'hFFFFFFFF;
			default : return 32'h80000000;
		endcase
	endfunction : get_data
    
    

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : min_max_tester
