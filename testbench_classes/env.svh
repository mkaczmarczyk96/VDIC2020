class env extends uvm_env;
    `uvm_component_utils(env)

    base_tester tester_i;
    coverage coverage_i;
    scoreboard scoreboard_i;

    function void build_phase(uvm_phase phase);
        tester_i     = base_tester::type_id::create("tester_i",this);
        coverage_i   = coverage::type_id::create ("coverage_i",this);
        scoreboard_i = scoreboard::type_id::create("scoreboard_i",this);
    endfunction : build_phase

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

endclass
