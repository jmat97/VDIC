class scoreboard extends uvm_subscriber #(shortint);	
	`uvm_component_utils(scoreboard)
	
	virtual alu_bfm bfm;
	uvm_tlm_analysis_fifo #(command_s) cmd_f;

	string test_result = "PASSED";
	
	function new (string name, uvm_component parent);
        super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase
	
	function logic [31:0] get_expected(bit [98:0] Data, operation_t op_set); 
		bit [31:0] A,B,result;
		B = {Data[96:89],Data[85:78],Data[74:67],Data[63:56]};
		A = {Data[52:45],Data[41:34],Data[30:23],Data[19:12]};
		case(op_set)
	        and_op : result = A & B;
	        or_op :  result = A | B;
	        add_op : result = A + B;
	        sub_op : result = B - A;
			inv_op : begin 
				`ifdef DEBUG
				$display("%0t Expected error", $time);
				`endif
			end
			rst_op : begin 
				`ifdef DEBUG
				$display("%0t Reset operation", $time);
				`endif
			end
	        default: begin
	            $display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %b", $time, op_set);
		        test_result = "FAILED";
	            return -1;
	        end
		endcase
		return (result);
	endfunction
	
	function void result();
		$display("Test %s.",test_result);
	endfunction

function void write (shortint t); 	    
    int predicted_result, result;
	command_s cmd;
	cmd.op_set = rst_op;
	do
	        if (!cmd_f.try_get(cmd))
	            $fatal(1, "Unknown command");
	while(cmd.op_set == rst_op); 
    predicted_result = get_expected(cmd.Data, cmd.op_set);
    if(cmd.data_out[54:53] == 2'b00 )begin
        result = {cmd.data_out[52:45],cmd.data_out[41:34],cmd.data_out[30:23],cmd.data_out[19:12]};	  
        assert(result === predicted_result) begin
            `ifdef DEBUG
            $display("Test passed - oeration OK");
            `endif
        end
        else begin
            `ifdef DEBUG
        	$display("Test FAILED - oeration NOT OK");
        	$display("Expected: %d  received: %d", predicted_result, result);
            `endif
            test_result = "FAILED";
        end;
    end
         
endfunction

function void report_phase(uvm_phase phase);
	result();
endfunction

endclass : scoreboard


