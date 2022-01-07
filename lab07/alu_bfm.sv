import alu_pkg::*;
interface alu_bfm;
import uvm_pkg::*;
`include "uvm_macros.svh"

bit                clk;
bit                rst_n;
logic                sin;
logic        	   sout;
operation_t        op_set;
operation_t        op;
	

bit [98:0] Data, Data1;
bit [54:0] data_out;
bit [31:0] expected, result; 
bit [2:0] expected_error,expected_error1;
bit [31:0] A,B;
bit done = 1'b0;
byte a;
	
command_monitor command_monitor_h;
result_monitor result_monitor_h;
	

initial begin
    clk = 0;
    forever begin
        #10;
        clk = ~clk;
    end
end

task reset_alu();
	sin = 1'b1;
    rst_n = 1'b0;
	done = 1'b0;
  	`uvm_info("ALU_BFM", "reset_alu", UVM_HIGH) 
    @(negedge clk);
    rst_n = 1'b1;
	
endtask

function [10:0] get_data_packet(input [7:0] data);  //get packet with data 
    return {2'b00, data, 1'b1};
endfunction : get_data_packet


function [10:0] get_ctl_packet(input [31:0] B, input [31:0] A, input [2:0] op);  //get packet with ctl 
	bit[3:0] crc;
	bit[67:0] xdata;
	xdata = {B,A,1'b1,op};
	crc = nextCRC4_D68(xdata);
    return {2'b01,1'b0, op, crc, 1'b1};
endfunction : get_ctl_packet

function [98:0] case_expected_error(input [98:0] Data, input [2:0] op_set,input [2:0] expected_error);
	bit [10:0] Data1,Data2,Data3,Data4,Data5,Data6,Data7,Data8,Data9;
    Data1      = get_data_packet(Data[96:89]); //TODO it better
    Data2      = get_data_packet(Data[85:78]);
    Data3      = get_data_packet(Data[74:67]);
    Data4      = get_data_packet(Data[63:56]);
    Data5      = get_data_packet(Data[52:45]);
    Data6      = get_data_packet(Data[41:34]);
    Data7      = get_data_packet(Data[30:23]);
    Data8      = get_data_packet(Data[19:12]);
	case(expected_error)   //TODO it better
        3'b000:begin //No error
            Data9      = get_ctl_packet({Data1[8:1], Data2[8:1], Data3[8:1], Data4[8:1]}, {Data5[8:1], Data6[8:1], Data7[8:1], Data8[8:1]}, op_set);
            end
        3'b001:begin //Error OP
            Data9      = get_ctl_packet({Data1[8:1], Data2[8:1], Data3[8:1], Data4[8:1]}, {Data5[8:1], Data6[8:1], Data7[8:1], Data8[8:1]}, op_set);        
            end
        3'b010:begin //Error CRC
            Data9      = get_ctl_packet({Data1[8:1], Data2[8:1], Data3[8:1], Data4[8:1]}, {Data5[8:1], Data6[8:1], Data7[8:1], Data8[8:1]}, op_set);
        	Data9[4:1] = 4'($random);
            end
        3'b100:begin //Error Data
            Data8      = get_ctl_packet({Data1[8:1], Data2[8:1], Data3[8:1], Data4[8:1]}, {Data5[8:1], Data6[8:1], Data7[8:1], Data8[8:1]}, op_set);
	        Data9[10:0] = 11'b11111111111;
        	end
        3'b111:begin //Error all 1
        	Data1[8:1] =8'hFF; 
	        Data2[8:1] =8'hFF;  
	        Data3[8:1] =8'hFF;  
	        Data4[8:1] =8'hFF;  
	        Data5[8:1] =8'hFF;  
	        Data6[8:1] =8'hFF;  
	        Data7[8:1] =8'hFF;  
	        Data8[8:1] =8'hFF;  
	        Data9      = get_ctl_packet({Data1[8:1], Data2[8:1], Data3[8:1], Data4[8:1]}, {Data5[8:1], Data6[8:1], Data7[8:1], Data8[8:1]}, op_set);	        
        end
        3'b011:begin //Error all 0
        	Data1[8:1] =8'b0; 
	        Data2[8:1] =8'b0; 
	        Data3[8:1] =8'b0; 
	        Data4[8:1] =8'b0; 
	        Data5[8:1] =8'b0; 
	        Data6[8:1] =8'b0; 
	        Data7[8:1] =8'b0; 
	        Data8[8:1] =8'b0; 
	        Data9      = get_ctl_packet({Data1[8:1], Data2[8:1], Data3[8:1], Data4[8:1]}, {Data5[8:1], Data6[8:1], Data7[8:1], Data8[8:1]}, op_set);	        
            end
        default:begin 
	        Data9      = get_ctl_packet({Data1[8:1], Data2[8:1], Data3[8:1], Data4[8:1]}, {Data5[8:1], Data6[8:1], Data7[8:1], Data8[8:1]}, op_set);	     
            end
	endcase	
	return   {Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9}; 		
endfunction

function [98:0] get_packet(input [98:0] random_data, input [2:0] op_set, input [2:0] expected_error);  //get packet with data 
	return   case_expected_error(random_data, op_set,expected_error);  
endfunction : get_packet


function bit [3:0] nextCRC4_D68(input [67:0] data_in);   
    reg [67:0] d;
    reg [3:0] c;
    reg [3:0] newcrc;
  	begin
	    d = data_in;
	    c = 4'b0000;
	    newcrc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
	    newcrc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
	    newcrc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
	    newcrc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
	    return newcrc;
  	end
endfunction : nextCRC4_D68
	

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
		end
	
endtask : send_data

task get_data(output bit [54:0] data_out);
	@(negedge sout);
	for(int j = $size(data_out)-1; j >= 0 ; j--) begin 
		@(negedge clk);
		data_out[j] <= sout;					
	end	
endtask : get_data


task send_op(input bit [98:0] Data, input bit [2:0] expected_error, input operation_t op_set);
	
	Data1 = get_packet(Data, op_set,expected_error);
	expected_error1 = expected_error;
	op = op_set;
	case (op_set) 
        RST_op: begin : case_rst_op
            reset_alu();		        
        end
        default: begin : case_default		
	        send_data(Data1,expected_error);	  	        
	        get_data(data_out);		        
			done = 1'b1;	
        end            
	endcase	
	@(negedge clk);
endtask : send_op



always @(posedge clk) begin : op_monitor
    static bit in_command = 0;
    if (done) begin : start_high 
        if (!in_command) begin : new_command
	        @(negedge clk)
            command_monitor_h.write_to_monitor(Data1,expected_error1,op);
            in_command = op_set; 
        end : new_command
    end : start_high
    else // start low
        in_command = 0;
end : op_monitor



always @(negedge rst_n) begin : rst_monitor    
    if (command_monitor_h != null) //guard against VCS time 0 negedge
        command_monitor_h.write_to_monitor(99'($random),3'b000,RST_op);
end : rst_monitor 



initial begin : result_monitor_thread
    forever begin
        @(posedge clk) ;
        if (done) begin
	        @(negedge clk);
	        result = {data_out[52:45],data_out[41:34],data_out[30:23],data_out[19:12]};
	        data_out = data_out;        
            result_monitor_h.write_to_monitor(result, data_out);
        	//done = 1'b0;
        end 
        done = 1'b0;
    end
end : result_monitor_thread

endinterface : alu_bfm


