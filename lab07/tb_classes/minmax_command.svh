class minmax_command extends random_command;
    `uvm_object_utils(minmax_command)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint minmax_only {
	    Data[96:89] ==  8'h0 && 
		Data[85:78] ==  8'h0 && 
		Data[74:67] ==  8'h0 &&  
		Data[63:56] ==  8'h0 &&    
		Data[52:45] ==  8'h0 &&  
	    Data[41:34] ==  8'h0 && 
	    Data[30:23] ==  8'h0 &&  
	    Data[19:12] ==  8'h0 ||
		Data[96:89] ==  8'hFF && 
		Data[85:78] ==  8'hFF && 
		Data[74:67] ==  8'hFF &&  
		Data[63:56] ==  8'hFF &&    
		Data[52:45] ==  8'hFF &&  
	    Data[41:34] ==  8'hFF && 
	    Data[30:23] ==  8'hFF &&  
	    Data[19:12] ==  8'hFF; };
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name="");
        super.new(name);
    endfunction
    
    
endclass : minmax_command


