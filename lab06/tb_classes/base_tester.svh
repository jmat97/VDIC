virtual class base_tester extends uvm_component;
    `uvm_component_utils(base_tester)
    uvm_put_port #(command_s) command_port;

    
    function new (string name, uvm_component parent);
    	super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
                command_port = new("command_port", this);
    endfunction : build_phase

    protected pure virtual function operation_t get_op();    
    protected pure virtual function operation_t get_valid_op();
    protected pure virtual function byte get_data();    
    protected pure virtual function [10:0] get_data_packet();   
    protected pure virtual function [10:0] get_ctl_packet(input [31:0] B, input [31:0] A, input [2:0] op);
	protected pure virtual function [98:0] get_packet(input [2:0] op_set, input [2:0] expected_error);
    protected pure virtual function bit [3:0] nextCRC4_D68(input [67:0] data_in);
    protected pure virtual function [2:0] expected_error(input [2:0] op_set);
    
    task run_phase(uvm_phase phase);
	    
	    command_s command;
	    
        phase.raise_objection(this);
        command.op_set = rst_op;
        command_port.put(command);

        repeat (100000) begin : random_loop
		    command.op_set 	   = get_op();	 
	        command.expected_error = expected_error(command.op_set);
	        command.Data = get_packet(command.op_set,command.expected_error);
			command_port.put(command);
        end : random_loop
        #500
        phase.drop_objection(this);
        
    endtask : run_phase

        
endclass : base_tester
