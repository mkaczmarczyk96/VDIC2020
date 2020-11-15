
class testbench;

    virtual alu_bfm bfm;

//------------------------------------------------------------------------------
// "New" auxiliary function
//------------------------------------------------------------------------------

    function new (virtual alu_bfm b);
        bfm = b;
    endfunction : new

    tester tester_i;
    coverage coverage_i;
    scoreboard scoreboard_i;


//------------------------------------------------------------------------------
// Execute task
//------------------------------------------------------------------------------

    task execute();

        tester_i     = new(bfm);
        coverage_i   = new(bfm);
        scoreboard_i = new(bfm);
	    
        fork
	        tester_i.execute();
            coverage_i.execute();
            scoreboard_i.execute();
        join_none

    endtask : execute
endclass : testbench
