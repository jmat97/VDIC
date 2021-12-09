interface alu_bfm;
import alu_pkg::*;

bit                clk;
bit                rst_n;
logic                sin;
logic        	   sout;
operation_t        op_set;

bit [98:0] Data;
bit [54:0] data_out;
bit [31:0] expected, result; 
bit [2:0] expected_error;
bit [31:0] A,B;
bit done;
byte a;

assign op = op_set;

initial begin
    clk = 0;
    forever begin
        #10;
        clk = ~clk;
    end
end

task reset_alu();
    rst_n = 1'b0;
	`ifdef DEBUG
    $display("%0t DEBUG: reset_alu", $time);
    `endif
    @(negedge clk);
    rst_n = 1'b1;
	sin = 1'b1;
endtask


task send_data(input bit [98:0] Data, input bit [2:0] expected_error);
          
	
        if (expected_error == 3'b100) begin
            a = 11;
        	end
        else begin
            a = 0;
        end      

        for(int i = $size(Data)-1; i >= a ; i--) begin 					
			@(negedge clk);
			sin = Data[i];	
			`ifdef DEBUG
			//$display("%0t DEBUG: send_data %b %b", $time, sin, Data[i]);
			`endif
		end
	
endtask : send_data

task get_data(output bit [54:0] data_out);
	@(negedge sout);
	for(int j = $size(data_out)-1; j >= 0 ; j--) begin 
		@(negedge clk);
		data_out[j] <= sout;					
	end	
endtask : get_data


task send_op(input command_s command);
	op_set = command.op_set;
	Data = command.Data;
	expected_error = command.expected_error;
	case (command.op_set) 
        rst_op: begin : case_rst_op
            reset_alu();	             
        end
        default: begin : case_default			            			          				    
	        send_data(command.Data,command.expected_error);	        
	        get_data(command.data_out);	
	        data_out = command.data_out;
			done = 1'b1;		        
        end            
	endcase	
	@(negedge clk);   
endtask : send_op

command_monitor command_monitor_h;


always @(posedge clk) begin : op_monitor
    static bit in_command = 0;
    command_s command;
    if (done) begin : start_high   	        
        if (!in_command) begin : new_command
            command.Data  <= Data;
            command.expected_error  <= expected_error ;
	        command.op_set <= op_set;
	        command.data_out <= data_out;
            command_monitor_h.write_to_monitor(command);
            in_command = command.op_set; 
        end : new_command
    end : start_high
    else // start low
        in_command = 0;
end : op_monitor



always @(negedge rst_n) begin : rst_monitor
    command_s command;
    command.op_set <= rst_op;
    if (command_monitor_h != null)
        command_monitor_h.write_to_monitor(command);
end : rst_monitor 

result_monitor result_monitor_h;

initial begin : result_monitor_thread
    forever begin
        @(posedge clk) ;
        if (done)
            result_monitor_h.write_to_monitor(data_out);
        	done = 1'b0;
    end
end : result_monitor_thread

endinterface : alu_bfm


