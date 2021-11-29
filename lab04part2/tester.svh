class tester;
    
    virtual alu_bfm bfm;  
    
    function new (virtual alu_bfm b);
        bfm = b;
    endfunction : new

    task execute();
        automatic queue_elem_t elem;
        bfm.reset_alu();
        repeat (100000) begin : tester_main

            elem.destroy_op        = $urandom() % 2; 
            elem.destroy_crc       = $urandom() % 2;
            elem.destroy_operand   = $urandom() % 2; 
            elem.destroy_byte_count= $urandom() % 2;
	        
            elem.op_set = get_op(elem.destroy_op);
            elem.A      = get_data();
            elem.B      = get_data();  
            
            bfm.enqueue_element(elem);

        end
    endtask
       
    //---------------------------------
    // Random data generation functions
    
    protected function operation_t get_op(input bit destroy);
        bit [2:0] op_choice;
        op_choice = destroy ? $urandom_range(7,4) : $urandom_range(3,0);
        case (op_choice)
            0 : return alu_pkg::and_op;
            1 : return alu_pkg::or_op;
            2 : return alu_pkg::add_op;
            3 : return alu_pkg::sub_op;
            4 : return alu_pkg::inv_op1;
            5 : return alu_pkg::inv_op2;
            6 : return alu_pkg::inv_op3;
            7 : return alu_pkg::inv_op4;
        endcase 
    endfunction : get_op
    
    //---------------------------------
    protected function bit [31:0] get_data();
        bit [1:0] zero_ones;
        zero_ones = 2'($random);
        if (zero_ones == 2'b00)
            return 32'h00000000;
        else if (zero_ones == 2'b11)
            return 32'hFFFFFFFF;
        else
            return 32'($random);
    endfunction : get_data
    
endclass