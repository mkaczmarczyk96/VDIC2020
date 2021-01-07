class random_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(random_sequence)

    sequence_item command;

    function new(string name = "random_sequence");
        super.new(name);
    endfunction : new

    task body();
        `uvm_info("SEQ_RANDOM","",UVM_MEDIUM)
        
        `uvm_create(command);
        
        repeat (100) begin : random_loop
           `uvm_rand_send(command)
        end : random_loop
    endtask : body

endclass : random_sequence
