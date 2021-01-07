class runall_sequence extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(runall_sequence)

    protected reset_sequence reset;
    protected min_max_sequence minmax;
    protected random_sequence random;

    protected sequencer sequencer_h;
    protected uvm_component uvm_component_h;

    function new(string name = "runall_sequence");
        super.new(name);

        uvm_component_h = uvm_top.find("*.env_h.sequencer_h");

        if (uvm_component_h == null)
            `uvm_fatal("RUNALL SEQUENCE", "Failed to get the sequencer")

        if (!$cast(sequencer_h, uvm_component_h))
            `uvm_fatal("RUNALL SEQUENCE", "Failed to cast from uvm_component_h.")


        reset = reset_sequence::type_id::create("reset");
        minmax = min_max_sequence::type_id::create("minmax");
        random = random_sequence::type_id::create("random");
    endfunction : new

    task body();
        reset.start(sequencer_h);
        minmax.start(sequencer_h);
        random.start(sequencer_h);
    endtask : body

endclass : runall_sequence
