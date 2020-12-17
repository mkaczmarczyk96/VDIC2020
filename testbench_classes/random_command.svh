class random_command extends uvm_transaction;
	`uvm_object_utils(random_command)

	rand bit [31:0] A;
	rand bit [31:0] B;

	rand Current_state_t Current_state;
	operation_t op;
	
	function void do_copy(uvm_object rhs);
		random_command copied_transaction_h;

		if(rhs == null)
			`uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

		super.do_copy(rhs);

		if(!$cast(copied_transaction_h,rhs))
			`uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

		A  = copied_transaction_h.A;
		B  = copied_transaction_h.B;
		op = copied_transaction_h.op;

	endfunction : do_copy

	function bit do_compare(uvm_object rhs, uvm_comparer comparer);
		random_command compared_transaction_h;
		bit identical;

		if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
				"Tried to do comparison to a null pointer");

		if (!$cast(compared_transaction_h,rhs))
			identical = 0;
		else
			identical = super.do_compare(rhs, comparer) && (compared_transaction_h.A == A) && (compared_transaction_h.B == B) && (compared_transaction_h.op == op);
		return identical;
	endfunction : do_compare


	function string convert2string();
		string s;
		s = $sformatf("A: %2h  B: %2h op: %s",
			A, B, op.name());
		return s;
	endfunction : convert2string

	function new (string name = "");
		super.new(name);
	endfunction : new

endclass : random_command
