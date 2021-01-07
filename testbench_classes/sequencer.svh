`ifndef IFNDEF_GUARD_mtm_ALU_sequencer
`define IFNDEF_GUARD_mtm_ALU_sequencer

class sequencer extends uvm_sequencer #(sequence_item);
	
	`uvm_component_utils(sequencer)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : sequencer
