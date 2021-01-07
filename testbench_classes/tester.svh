class tester extends uvm_component;
	`uvm_component_utils(tester)

	uvm_put_port #(random_command) command_port;

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		command_port = new("command_port", this);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		random_command command;

		phase.raise_objection(this);

		command = new("command");
		command.state = rst_state;
		command_port.put(command);

		repeat (10000) begin : tester_main
			command = random_command::type_id::create("command");
			assert(command.randomize());
			case(command.state)
				add_state: command.op = add_op;
				sub_state: command.op = sub_op;
				and_state: command.op = and_op;
				or_state: command.op = or_op;
				default: command.op = and_op;
			endcase
			command_port.put(command);
		end

		#500;
		phase.drop_objection(this);
	endtask

endclass : tester
