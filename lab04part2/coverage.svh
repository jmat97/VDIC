class coverage;

    virtual alu_bfm bfm;


       covergroup op_cov;	   
	   
      option.name = "cg_op_cov";

      coverpoint bfm.e_temp.op_set {
         // #A1 test all alu operations
         bins A1_op[] = {[and_op : sub_op]};

         //#A2 three operations in a row
         bins A2_three_ops[] = ([add_op:sub_op] [* 3]);
	      
	     	//#A3 two errors in row
         bins A3_two_inv_ops[] = ([inv_op1 : inv_op4] [* 2]);
	      
	      // #A4 Valid operation after invalid
         bins A4_valid_after_invalid[] = ([inv_op1 : inv_op4] => [and_op:sub_op]);

      }

       endgroup
       
       
        covergroup data_cov;
        
        option.name = "cg_data_cov";  
        
        all_ops : coverpoint bfm.e_temp.op_set {
            ignore_bins null_ops = {inv_op1,inv_op2,inv_op3,inv_op4};
        }
        
        a_leg : coverpoint bfm.e_temp.A {
            bins zeros = {'h00000000};
            bins ones  = {'hffffffff};
        }
        b_leg : coverpoint bfm.e_temp.B {
            bins zeros = {'h00000000};
            bins ones  = {'hffffffff};
        }
        
        B_data_00_FF: cross a_leg, b_leg, all_ops {
            
            // #B.1 simulate zeros at A ones at B for all the operations
            bins B1_and          = binsof (all_ops) intersect {and_op} && (binsof (a_leg.zeros) || binsof (b_leg.ones));
            bins B1_or          = binsof (all_ops) intersect {or_op} && (binsof (a_leg.zeros) || binsof (b_leg.ones));
            bins B1_add          = binsof (all_ops) intersect {add_op} && (binsof (a_leg.zeros) || binsof (b_leg.ones));
            bins B1_sub          = binsof (all_ops) intersect {sub_op} && (binsof (a_leg.zeros) || binsof (b_leg.ones));
            
            // #B.2 zeros at inputs for or operation
            bins B2_or_zeros          = binsof (all_ops) intersect {or_op} && (binsof (a_leg.zeros) || binsof (b_leg.zeros));
            	        
        }
        
    endgroup


    
    function new (virtual alu_bfm b);
        op_cov      = new();
        data_cov      = new();
        bfm         = b;
    endfunction : new
    
    task execute(); 
        forever begin : sample_cov
            @(bfm.check_coverage) begin
                op_cov.sample();
                data_cov.sample();
            end
        end  
    endtask

endclass