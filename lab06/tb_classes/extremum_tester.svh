class extremum_tester extends random_tester;	
	`uvm_component_utils(extremum_tester)
	

	
	protected function [98:0] get_packet(input [2:0] op_set, input [2:0] expected_error);  //get packet with data 
		bit [10:0] Data1,Data2,Data3,Data4,Data5,Data6,Data7,Data8,Data9;
		bit zero_ones;
	    Data1      = get_data_packet(); //TODO it better
	    Data2      = get_data_packet();
	    Data3      = get_data_packet();
	    Data4      = get_data_packet();
	    Data5      = get_data_packet();
	    Data6      = get_data_packet();
	    Data7      = get_data_packet();
	    Data8      = get_data_packet();
		zero_ones = 1'($random);
	    if (zero_ones == 1'b0) begin
	    	Data1[8:1] =8'b0; 
	        Data2[8:1] =8'b0; 
	        Data3[8:1] =8'b0; 
	        Data4[8:1] =8'b0; 
	        Data5[8:1] =8'b0; 
	        Data6[8:1] =8'b0; 
	        Data7[8:1] =8'b0; 
	        Data8[8:1] =8'b0; 
		    end
	    else begin
        	Data1[8:1] =8'hFF; 
	        Data2[8:1] =8'hFF;  
	        Data3[8:1] =8'hFF;  
	        Data4[8:1] =8'hFF;  
	        Data5[8:1] =8'hFF;  
	        Data6[8:1] =8'hFF;  
	        Data7[8:1] =8'hFF;  
	        Data8[8:1] =8'hFF; 	  
	    end
	    Data9      = get_ctl_packet({Data1[8:1], Data2[8:1], Data3[8:1], Data4[8:1]}, {Data5[8:1], Data6[8:1], Data7[8:1], Data8[8:1]}, op_set);				    
	    return   {Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9};   
	endfunction : get_packet
	
	function new (string name, uvm_component parent);
    super.new(name, parent);
	endfunction : new
		
endclass : extremum_tester
