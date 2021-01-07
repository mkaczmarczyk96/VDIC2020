class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

    virtual alu_bfm bfm;
    uvm_analysis_port #(sequence_item) ap;

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")

        ap = new("ap",this);
    endfunction : build_phase
    
      function void connect_phase(uvm_phase phase);
        bfm.command_monitor_h = this;
    endfunction : connect_phase

    function void write_to_monitor(bit[31:0] A, bit[31:0] B, operation_t op, state_t state);
	    sequence_item cmd;

	    cmd = new("cmd");
	    cmd.A = A;
	    cmd.B = B;
	    cmd.state = state;
        ap.write(cmd);
    endfunction : write_to_monitor

endclass : command_monitor
