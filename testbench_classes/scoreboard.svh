class scoreboard extends uvm_subscriber #(out_element_s);
	`uvm_component_utils(scoreboard)

	virtual alu_bfm bfm;
	uvm_tlm_analysis_fifo #(command_s) cmd_f;

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		cmd_f = new("cmd_f", this);
	endfunction : build_phase



	function void write(out_element_s t);

		out_element_s expected_data;
		command_s cmd;
		bit carry, overflow, negative, zero;

		//init
		{carry,overflow,zero,negative} = 4'b0000;
		cmd.A = 0;
		cmd.B = 0;
		cmd.Current_state = RST_s;
		cmd.op = ADD;
		//


		do
			if (!cmd_f.try_get(cmd))
				$fatal(1, "Missing command!");
		while(cmd.Current_state == RST_s);
		


		case(cmd.op)
			ADD: begin
				{carry,expected_data.result} = cmd.A + cmd.B;
				overflow = (cmd.A[31] & cmd.B[31] & ~expected_data.result[31])|(~cmd.A[31] & ~cmd.B[31] & expected_data.result[31]);
			end
			SUB: begin
				{carry,expected_data.result} = cmd.B - cmd.A;
				overflow = (cmd.B[31] & ~cmd.A[31] & ~expected_data.result[31])|(~cmd.B[31] & cmd.A[31] & expected_data.result[31]);
			end
			OR: expected_data.result = cmd.A | cmd.B;
			AND: expected_data.result = cmd.A & cmd.B;
		endcase
		zero = ~(|expected_data.result);
		negative = expected_data.result[31];
		expected_data.flags = {carry,overflow,zero,negative};
		
		 if (expected_data != t)begin
			bfm.error = 1;
		end
		
	endfunction


endclass : scoreboard
