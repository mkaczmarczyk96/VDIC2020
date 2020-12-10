class scoreboard extends uvm_subscriber #(result_transaction);
	`uvm_component_utils(scoreboard)

	virtual alu_bfm bfm;
	uvm_tlm_analysis_fifo #(random_command) cmd_f;

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		cmd_f = new("cmd_f", this);
	endfunction : build_phase

	function result_transaction predict_result(random_command cmd);
		result_transaction predicted;
		out_element_s expected_data;
		bit carry, overflow, negative, zero;
		{carry,overflow,negative,zero} = 4'b0000;

		predicted = new("predicted");

		case(cmd.op)
			ADD: begin
				{carry,expected_data.result} = cmd.A + cmd.B;
				overflow = (cmd.A[31] & cmd.B[31] & ~expected_data.result[31])|(~cmd.A[31] & ~cmd.B[31] & expected_data.result[31]);
			end
			SUB: begin
				{carry,expected_data.result} = cmd.B - cmd.A;
				overflow = (cmd.B[31] & ~cmd.A[31] & ~expected_data.result[31])|(~cmd.B[31] & cmd.A[31] & expected_data.result[31]);
			end
			AND: expected_data.result = cmd.A & cmd.B;
			OR: expected_data.result = cmd.A | cmd.B;
		endcase
		zero = ~(|expected_data.result);
		negative = expected_data.result[31];
		expected_data.flags = {carry,overflow,zero,negative};

		predicted.result = expected_data;
		return predicted;
	endfunction


	//Checker
	function void write(result_transaction t);
		string data_string;
		random_command cmd;
		result_transaction predicted;

		do
			if (!cmd_f.try_get(cmd))
				$fatal(1, "Missing command in self checker");
		while(cmd.Current_state == RST_s);

		predicted = predict_result(cmd);

		data_string = { cmd.convert2string()," Actual " , t.convert2string(), " Predicted ",predicted.convert2string()};

		if (!predicted.compare(t))
			`uvm_error("SELF CHECKER", {"FAIL: ",data_string})
		else
			`uvm_info ("SELF CHECKER", {"PASS: ", data_string}, UVM_HIGH)

	endfunction

endclass : scoreboard
