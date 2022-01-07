class random_command extends uvm_transaction;
    `uvm_object_utils(random_command)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

    rand bit unsigned [98:0] Data;
    rand bit unsigned [2:0] expected_error;
    rand operation_t op_set;

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint data {						
        Data[96:89] dist {8'h0:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};
	    Data[85:78] dist {8'h0:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};
	    Data[74:67] dist {8'h0:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};
	    Data[63:56] dist {8'h0:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};
	    Data[52:45] dist {8'h0:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};
	    Data[41:34] dist {8'h0:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};
	    Data[30:23] dist {8'h0:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};
	    Data[19:12] dist {8'h0:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};
    }

    constraint error {
        expected_error dist {3'b000 := 10, [3'b001 : 3'b111]:=1};
    }
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name = "");
        super.new(name);
    endfunction : new    
//------------------------------------------------------------------------------
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------

    function void do_copy(uvm_object rhs);
        random_command copied_transaction_h;

        if(rhs == null)
            `uvm_fatal("RANDOM COMMAND", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("RANDOM COMMAND", "Tried to copy wrong type.")

        Data  = copied_transaction_h.Data;
        expected_error  = copied_transaction_h.expected_error;
        op_set = copied_transaction_h.op_set;

    endfunction : do_copy


    function random_command clone_me();
        
        random_command clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me


    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        
        random_command compared_transaction_h;
        bit same;

        if (rhs==null) `uvm_fatal("RANDOM COMMAND",
                "Tried to do comparison to a null pointer");

        if (!$cast(compared_transaction_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (compared_transaction_h.Data == Data) &&
            (compared_transaction_h.expected_error == expected_error) &&
            (compared_transaction_h.op_set == op_set);

        return same;
        
    endfunction : do_compare


    function string convert2string();
        string s;
        s = $sformatf("Data: %25h  expected_error: %3b op_set: %3b", Data, expected_error, op_set);
        return s;
    endfunction : convert2string



endclass : random_command


