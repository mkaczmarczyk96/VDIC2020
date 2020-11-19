class random_tester extends base_tester;
    
    `uvm_component_utils (random_tester)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new


	function Current_state_t get_state();
		
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

	function bit [31:0] get_data();
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

endclass : random_tester
