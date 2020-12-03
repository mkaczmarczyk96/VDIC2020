class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

    uvm_analysis_port #(command_s) ap;

    function void write_to_monitor(command_s command);
        ap.write(command);
    endfunction : write_to_monitor

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


endclass : command_monitor
