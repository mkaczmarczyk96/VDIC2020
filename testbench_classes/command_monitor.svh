class command_monitor extends uvm_component;
    	`uvm_component_utils(command_monitor)

	uvm_analysis_port #(random_command) ap;

	function new (string name, uvm_component parent);
		super.new(name,parent);
	endfunction

   	 function void build_phase(uvm_phase phase);
    	    virtual alu_bfm bfm;

		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
		    $fatal(1, "Failed to get BFM");

		bfm.command_monitor_h = this;

		ap = new("ap",this);

  	  endfunction : build_phase

    	function void write_to_monitor(bit[31:0] A, bit[31:0] B, operation_t op, Current_state_t Current_state);
	
	  	 random_command cmd;

	  	 cmd = new("cmd");
	   	 cmd.A = A;
	   	 cmd.B = B;
	   	 cmd.op = op;
	   	 cmd.Current_state = Current_state;
		 ap.write(cmd);
   	 endfunction : write_to_monitor

endclass : command_monitor
