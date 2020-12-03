`define Number_of_tests 10000

virtual class base_tester extends uvm_component;
	`uvm_component_utils(base_tester)
	uvm_put_port #(command_s) command_port;
	
   	function new (string name, uvm_component parent);
        	super.new(name, parent);
    	endfunction : new
    
	function void build_phase(uvm_phase phase);
		command_port = new("command_port", this);
	endfunction : build_phase   

    pure virtual function Current_state_t get_state();

    pure virtual function bit [31:0 ]get_data();

//------------------------------------------------------------------------------
// Run task
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);
		command_s command;
		phase.raise_objection(this);
		
		command.Current_state = RST_s;
		command_port.put(command);
		
		repeat (`Number_of_tests) begin : tester_main_loop
			command.Current_state = get_state();
			command.A = get_data();
			command.B = get_data();
			command_port.put(command);
		end : tester_main_loop
		
		#500;
		phase.drop_objection(this);
	endtask : run_phase
	
endclass : base_tester











