class result_transaction extends uvm_transaction;

   out_element_s result;

   function new(string name = "");
      super.new(name);
   endfunction : new

   function string convert2string();
      string s;
      s = $sformatf("result: %4h",result);
      return s;
   endfunction : convert2string

   function void do_copy(uvm_object rhs);
      result_transaction copied_transaction_h;
      assert(rhs != null) else
        $fatal(1,"Tried to copy null transaction");
      super.do_copy(rhs);
      assert($cast(copied_transaction_h,rhs)) else
        $fatal(1,"Failed cast");
      result = copied_transaction_h.result;
   endfunction : do_copy

   function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      result_transaction RHS;
      bit identical;
      assert(rhs != null) else
      		$fatal(1,"compared empty transaction");

      identical = super.do_compare(rhs, comparer);

      $cast(RHS, rhs);
      identical = (result == RHS.result) && identical;
      return identical;
   endfunction : do_compare

endclass : result_transaction
