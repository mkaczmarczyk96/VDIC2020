class reset_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(reset_sequence)

    function new(string name = "reset");
        super.new(name);
    endfunction : new

    task body();
        `uvm_info("SEQ_RESET", "", UVM_MEDIUM)
        `uvm_do_with(req, {state == rst_state;} )
    endtask : body
endclass : reset_sequence
