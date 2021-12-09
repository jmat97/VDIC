class coverage extends uvm_subscriber #(command_s);	
	`uvm_component_utils(coverage)
	
	//virtual alu_bfm bfm;
	
	bit [98:0] Data;
	bit [2:0] expected_error;
	operation_t op_set;

// Covergroup checking the op codes and their sequences
covergroup op_cov;

    option.name = "cg_op_cov";

    coverpoint op_set {
         // #A1 test all alu operations
         bins A1_op[] = {[and_op : sub_op]};
	    
        // #A2 test all operations after reset
        bins A2_rst_opn[]      = (rst_op => add_op, or_op, and_op, sub_op);

	     	//#A3 two errors in row
        bins A3_two_inv_ops[] = (inv_op [* 2]);
	      
	      // #A4 Valid operation after invalid
        bins A4_valid_after_invalid[] = (inv_op => [and_op:sub_op]);

    }

endgroup


covergroup data_cov;

    option.name = "data_cov";

    all_ops : coverpoint op_set {
        ignore_bins null_ops = {rst_op, inv_op};
    }

	
    a1_leg: coverpoint Data[19:12] {
        bins zeros = {8'b00000000};
        bins ones  = {8'b11111111};
    }
    
    a2_leg: coverpoint Data[30:23] {
        bins zeros = {8'b00000000};
        bins ones  = {8'b11111111};
    }
    
    a3_leg: coverpoint Data[41:34] {
        bins zeros = {8'b00000000};
        bins ones  = {8'b11111111};
    }
    
    a4_leg: coverpoint Data[52:45] {
        bins zeros = {8'b00000000};
        bins ones  = {8'b11111111};
    }   
	
    b1_leg: coverpoint Data[63:56] {
        bins zeros = {8'b00000000};
        bins ones  = {8'b11111111};
    }
    
    b2_leg: coverpoint Data[74:67] {
        bins zeros = {8'b00000000};
        bins ones  = {8'b11111111};
    }
    
    b3_leg: coverpoint Data[85:78] {
        bins zeros = {8'b00000000};
        bins ones  = {8'b11111111};
    }
    
    b4_leg: coverpoint Data[96:89] {
        bins zeros = {8'b00000000};
        bins ones  = {8'b11111111};
    }

    B_op_00_FF: cross a1_leg, b1_leg,a2_leg, b2_leg, a3_leg, b3_leg, a4_leg, b4_leg, all_ops {

        // #B1 simulate all zero input for all the operations

        bins B1_add_00          = binsof (all_ops) intersect {add_op} &&
        ((binsof (a1_leg.zeros) && binsof (a2_leg.zeros) && binsof (a3_leg.zeros) && binsof (a4_leg.zeros))||
	     (binsof (b1_leg.zeros) && binsof (b2_leg.zeros) && binsof (b3_leg.zeros) && binsof (b4_leg.zeros)));

        bins B1_and_00          = binsof (all_ops) intersect {and_op} &&
        ((binsof (a1_leg.zeros) && binsof (a2_leg.zeros) && binsof (a3_leg.zeros) && binsof (a4_leg.zeros))|| 
	     (binsof (b1_leg.zeros) && binsof (b2_leg.zeros) && binsof (b3_leg.zeros) && binsof (b4_leg.zeros)));

        bins B1_or_00          = binsof (all_ops) intersect {or_op} &&
        ((binsof (a1_leg.zeros) && binsof (a2_leg.zeros) && binsof (a3_leg.zeros) && binsof (a4_leg.zeros))|| 
	     (binsof (b1_leg.zeros) && binsof (b2_leg.zeros) && binsof (b3_leg.zeros) && binsof (b4_leg.zeros)));

        bins B1_sub_00          = binsof (all_ops) intersect {sub_op} &&
        ((binsof (a1_leg.zeros) && binsof (a2_leg.zeros) && binsof (a3_leg.zeros) && binsof (a4_leg.zeros))|| 
	     (binsof (b1_leg.zeros) && binsof (b2_leg.zeros) && binsof (b3_leg.zeros) && binsof (b4_leg.zeros)));

        // #B2 simulate all one input for all the operations

        bins B2_add_FF          = binsof (all_ops) intersect {add_op} &&
        ((binsof (a1_leg.ones) && binsof (a2_leg.ones) && binsof (a3_leg.ones) && binsof (a4_leg.ones))|| 
	     (binsof (b1_leg.ones) && binsof (b2_leg.ones) && binsof (b3_leg.ones) && binsof (b4_leg.ones)));

        bins B2_and_FF          = binsof (all_ops) intersect {and_op} &&
        ((binsof (a1_leg.ones) && binsof (a2_leg.ones) && binsof (a3_leg.ones) && binsof (a4_leg.ones))||
	     (binsof (b1_leg.ones) && binsof (b2_leg.ones) && binsof (b3_leg.ones) && binsof (b4_leg.ones)));

        bins B2_or_FF          = binsof (all_ops) intersect {or_op} &&
        ((binsof (a1_leg.ones) && binsof (a2_leg.ones) && binsof (a3_leg.ones) && binsof (a4_leg.ones))|| 
	     (binsof (b1_leg.ones) && binsof (b2_leg.ones) && binsof (b3_leg.ones) && binsof (b4_leg.ones)));

        bins B2_sub_FF          = binsof (all_ops) intersect {sub_op} &&
        ((binsof (a1_leg.ones) && binsof (a2_leg.ones) && binsof (a3_leg.ones) && binsof (a4_leg.ones))|| 
	     (binsof (b1_leg.ones) && binsof (b2_leg.ones) && binsof (b3_leg.ones) && binsof (b4_leg.ones)));
	     
	     ignore_bins others_only =
	   	  (!binsof (a1_leg.zeros)|| !binsof (a2_leg.zeros) || !binsof (a3_leg.zeros) || !binsof (a4_leg.zeros))&&
	      (!binsof (b1_leg.zeros) || !binsof (b2_leg.zeros) || !binsof (b3_leg.zeros) || !binsof (b4_leg.zeros)) &&
		  (!binsof (a1_leg.ones) || !binsof (a2_leg.ones)  || !binsof (a3_leg.ones)  || !binsof (a4_leg.ones))&& 
	      (!binsof (b1_leg.ones) || !binsof (b2_leg.ones) || !binsof (b3_leg.ones) || !binsof (b4_leg.ones));
    }

endgroup

function new (string name, uvm_component parent);
    super.new(name, parent);
	op_cov      = new();
    data_cov = new();
endfunction : new

function void write(command_s t);
	Data      = t.Data;
	op_set    = t.op_set;
	expected_error = t.expected_error;	    
	op_cov.sample();
	data_cov.sample();
endfunction : write

endclass : coverage





