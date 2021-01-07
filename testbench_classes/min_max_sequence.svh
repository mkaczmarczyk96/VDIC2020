class min_max_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(min_max_sequence)

    sequence_item command;

    function new(string name = "maxmin_sequence");
        super.new(name);
    endfunction : new

    task body();
        `uvm_info("SEQ_maxmin", "", UVM_MEDIUM)
        `uvm_create(command)
	
        repeat (2000) begin : random_loop
        	`uvm_rand_send_with(command,{state dist {add_state := 1, and_state:=1, or_state:=1,sub_state:=1, rst_state:=1}; A dist {32'h00000000:=1, 32'h00000001:= 1,32'hFFFFFFFE:=1, 32'h80000000:=1, 32'h80000001:=1, 32'h7FFFFFFF:=1, 32'h7FFFFFFE:=1, 32'hFFFFFFFF:=1}; B dist {32'h00000000:=1, 32'h00000001:= 1,32'hFFFFFFFE:=1, 32'h80000000:=1, 32'h80000001:=1, 32'h7FFFFFFF:=1, 32'h7FFFFFFE:=1, 32'hFFFFFFFF:=1};})
        end : random_loop
	
    endtask : body

endclass : min_max_sequence
