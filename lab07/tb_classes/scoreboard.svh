class scoreboard extends uvm_subscriber #(result_transaction);	
	`uvm_component_utils(scoreboard)
	
	uvm_tlm_analysis_fifo #(random_command) cmd_f;

	typedef enum bit {
	        TEST_PASSED,
	        TEST_FAILED
	} test_result;
	
	protected test_result tr = TEST_PASSED;
	
	function new (string name, uvm_component parent);
        super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase

    protected function void print_test_result (test_result r);
        if(tr == TEST_PASSED) begin
            set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
            $write ("-----------------------------------\n");
            $write ("----------- Test PASSED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
        else begin
            set_print_color(COLOR_BOLD_BLACK_ON_RED);
            $write ("-----------------------------------\n");
            $write ("----------- Test FAILED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
    endfunction
    
	protected function result_transaction get_expected(random_command cmd); 
		result_transaction predicted;
		bit [31:0] A,B;
		predicted = new("predicted");
		
		
		B = {cmd.Data[96:89],cmd.Data[85:78],cmd.Data[74:67],cmd.Data[63:56]};
		A = {cmd.Data[52:45],cmd.Data[41:34],cmd.Data[30:23],cmd.Data[19:12]};
		case(cmd.op_set)
	        AND_op : predicted.result = A & B;
	        OR_op :  predicted.result = A | B;
	        ADD_op : predicted.result = A + B;
	        SUB_op : predicted.result = B - A;
			RST_op : begin 
				`uvm_info("GET EXPECTED", "RST_op", UVM_HIGH)
			end
	        default: begin
				`uvm_error("GET EXPECTED", "Internal error - unexpected op code")
				tr = TEST_FAILED;
	            //return -1;
	        end
		endcase
		return (predicted);
	endfunction

function void write (result_transaction t);
	string data_str;
	random_command cmd;
    result_transaction predicted;
	    
	do
	        if (!cmd_f.try_get(cmd)) begin
	           $fatal(1, "Missing command in self checker");
	        end	        
	while(cmd.op_set == RST_op); 


    predicted = get_expected(cmd);
	data_str  = { cmd.convert2string(),
            " ==>  Actual " , t.convert2string(),
            "/Predicted ",predicted.convert2string()};
    if(t.data_out[54:53] == 2'b00 )begin
        if (!predicted.compare(t)) begin
            `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
            tr = TEST_FAILED;
        end
        else
            `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)

    end
    else begin
        if(cmd.expected_error != 3'b000)
            case(t.data_out[52:45])
                8'b11001001:begin
	                `uvm_info("TEST", "Test passed - ERROR DATA", UVM_HIGH)
                end
                8'b10100101:begin
	                `uvm_info("TEST", "Test passed - ERROR CRC", UVM_HIGH)
                end
                8'b10010011:begin
	                `uvm_info("TEST", "Test passed - ERROR OP CODE", UVM_HIGH)
                end
                default: begin
	                `uvm_info("TEST", "Test passed - UNKNOWN ERROR", UVM_HIGH)
	            end	                    	
            endcase
        else begin
		        `uvm_error("TEST", "Test FAILED - unexpected error")
                tr = TEST_FAILED;
        end;
    end;          
endfunction

function void report_phase(uvm_phase phase);
	//result();
	super.report_phase(phase);
    print_test_result(tr);
endfunction

endclass : scoreboard


