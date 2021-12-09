class random_tester extends base_tester;	
	`uvm_component_utils (random_tester)
	
	//virtual alu_bfm bfm;
	
	
	protected virtual function operation_t get_op();
	    bit [2:0] op_choice;
	    op_choice = $random;
	    case (op_choice)
	        3'b000 : return and_op;
	        3'b001 : return or_op;
	        3'b010 : return inv_op;
	        3'b011 : return inv_op;
	        3'b100 : return add_op;
	        3'b101 : return sub_op;
	        3'b110 : return rst_op;
	        3'b111 : return rst_op;
	    endcase // case (op_choice)
	endfunction : get_op

	 protected virtual function operation_t get_valid_op();
	    bit [2:0] op_choice;
	    op_choice = $random;
	    case (op_choice)
	        3'b000 : return and_op;
	        3'b001 : return or_op;
	        3'b010 : return add_op;
	        3'b011 : return sub_op;
	        3'b100 : return and_op;
	        3'b101 : return or_op;
	        3'b110 : return add_op;
	        3'b111 : return sub_op;
	    endcase // case (op_choice)
	endfunction : get_valid_op


	protected virtual function byte get_data();
	    bit [1:0] zero_ones;
	    zero_ones = 2'($random);
	    if (zero_ones == 2'b00)
	        return 8'h00;
	    else if (zero_ones == 2'b11)
	        return 8'hFF;
	    else
			return 8'($random);
	endfunction : get_data


	protected virtual function [10:0] get_data_packet();  //get packet with data 
		bit[7:0] data;
		data = get_data();
	    return {2'b00, data, 1'b1};
	endfunction : get_data_packet
	
	
	protected virtual function [10:0] get_ctl_packet(input [31:0] B, input [31:0] A, input [2:0] op);  //get packet with ctl 
		bit[3:0] crc;
		bit[67:0] xdata;
		xdata = {B,A,1'b1,op};
		crc = nextCRC4_D68(xdata);
	    return {2'b01,1'b0, op, crc, 1'b1};
	endfunction : get_ctl_packet
	
	
	protected virtual function [98:0] get_packet(input [2:0] op_set, input [2:0] expected_error);  //get packet with data 
		bit [10:0] Data1,Data2,Data3,Data4,Data5,Data6,Data7,Data8,Data9;
	    Data1      = get_data_packet(); //TODO it better
	    Data2      = get_data_packet();
	    Data3      = get_data_packet();
	    Data4      = get_data_packet();
	    Data5      = get_data_packet();
	    Data6      = get_data_packet();
	    Data7      = get_data_packet();
	    Data8      = get_data_packet();
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
	endfunction : get_packet

	
	protected virtual function bit [3:0] nextCRC4_D68(input [67:0] data_in);   
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

	protected virtual function [2:0] expected_error(input [2:0] op_set);  //get packet with data 
		if (op_set == inv_op) begin
	        bit [2:0] zero_ones;
			zero_ones = 3'($random);
	        case(zero_ones)
	            3'b000:begin
		            expected_error = 3'b011; //Error all 0
		            op_set = get_valid_op();
		            end
	            3'b001:begin
		            expected_error = 3'b001; //Error OP
		            end
	            3'b010:begin
		            expected_error = 3'b010;  //Error CRC
		            end
	            3'b100:begin
		            expected_error = 3'b100; //Error Data
	            	end
	            3'b111:begin
		            expected_error = 3'b111; //Error all 1
		            op_set = get_valid_op();
		            end
	            default:begin
		            expected_error = 3'b110;
		            end
	        endcase
		end
		else if (op_set == rst_op) begin
			expected_error = 3'b110;
			end
		else  begin
			expected_error = 3'b000;
		end
	    return expected_error;
	endfunction : expected_error

	function new (string name, uvm_component parent);
        super.new(name, parent);
	endfunction : new
	
endclass : random_tester
