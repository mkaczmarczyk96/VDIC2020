class sequence_item extends uvm_sequence_item;
//   `uvm_object_utils(sequence_item)
	rand bit [31:0] A;
	rand bit [31:0] B;
	rand state_t state;
	//operation_t op;

    constraint state_con {state dist {add_state := 1, and_state:=1, or_state:=1,sub_state:=1, rst_state:=1};}

    //constraint data { A dist {32'h00000000:=1, 32'h00000001:= 1,[32'h00000002 : 32'hF7FFFFFFD]:=1, 32'h7FFFFFFF:=1, 32'h7FFFFFFE:=1,32'h80000000:=1, 32'h80000001:=1,[32'h80000002 : 32'hFFFFFFFD]:=1, 32'hFFFFFFFE:=1, 32'hFFFFFFFF:=1};
    //   A dist {32'h00000000:=1, 32'h00000001:= 1,[32'h00000002 : 32'hF7FFFFFFD]:=1, 32'h7FFFFFFF:=1, 32'h7FFFFFFE:=1,32'h80000000:=1, 32'h80000001:=1,[32'h80000002 : 32'hFFFFFFFD]:=1, 32'hFFFFFFFE:=1, 32'hFFFFFFFF:=1};}
    
    constraint data { A dist {[32'h00000000 : 32'hFFFFFFFF]:=1};
       B dist {[32'h00000000 : 32'hFFFFFFFF]:=1};}
    
    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

    `uvm_object_utils_begin(sequence_item)
        `uvm_field_int(A, UVM_ALL_ON)
        `uvm_field_int(B, UVM_ALL_ON)
        `uvm_field_enum(state_t, state, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function string convert2string();
        string s;
        s = $sformatf("A: %2h  B: %2h   op: %s ",A, B, state.name());
        return s;
    endfunction : convert2string

endclass : sequence_item


