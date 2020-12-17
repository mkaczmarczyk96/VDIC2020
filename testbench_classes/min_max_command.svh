class min_max_command extends random_command;
	`uvm_object_utils(min_max_command)
	
	constraint data { 
		A dist {32'h00000000:=1, 32'h00000001:= 1,32'hFFFFFFFE:=1, 32'h80000000:=1, 32'h80000001:=1, 32'h7FFFFFFF:=1, 32'h7FFFFFFE:=1, 32'hFFFFFFFF:=1};
		B dist {32'h00000000:=1, 32'h00000001:=1, 32'hFFFFFFFE:=1, 32'h80000000:=1, 32'h80000001:=1, 32'h7FFFFFFF:=1, 32'h7FFFFFFE:=1, 32'hFFFFFFFF:=1};
		}
	
	function new (string name = "");
		super.new(name);
	endfunction : new

endclass : min_max_command
