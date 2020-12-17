`define Number_of_tests 10000

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
		command.Current_state = RST_s;
		command_port.put(command);

		repeat (`Number_of_tests) begin : tester_main
			command = random_command::type_id::create("command");
			assert(command.randomize());
			case(command.Current_state)
				ADD_s: command.op = ADD;
				SUB_s: command.op = SUB;
				AND_s: command.op = AND;
				OR_s: command.op = OR;
				default: command.op = AND;
			endcase
			command_port.put(command);
		end

		phase.drop_objection(this);
	endtask
	
endclass : tester
