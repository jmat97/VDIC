class extremum_tester extends random_tester;	
	`uvm_component_utils(extremum_tester)
	

	
protected virtual function byte get_data();
    bit [1:0] zero_ones;
    zero_ones = 2'($random);
    if (zero_ones == 2'b00)
        return 8'h00;
    else if (zero_ones == 2'b11)
        return 8'hFF;
endfunction : get_data
	
	function new (string name, uvm_component parent);
    super.new(name, parent);
	endfunction : new
		
endclass : extremum_tester
