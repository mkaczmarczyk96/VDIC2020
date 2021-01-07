class full_test extends alu_base_test;
   `uvm_component_utils(full_test)
   
   runall_sequence runall_seq;

   task run_phase(uvm_phase phase);
      runall_seq = new("runall_seq");
      phase.raise_objection(this);
      runall_seq.start(null);
      phase.drop_objection(this);
   endtask : run_phase


   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

endclass
