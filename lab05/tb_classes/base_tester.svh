/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
//`ifdef QUESTA
//virtual class base_tester extends uvm_component;
//`else
//`ifdef INCA
// irun requires abstract class when using virtual functions
// note: irun warns about the virtual class instantiation, this will be an
// error in future releases.
virtual class base_tester extends uvm_component;
//`else
//class base_tester extends uvm_component;
//`endif
//`endif

	`uvm_component_utils(base_tester)

	virtual alu_bfm bfm;

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
			$fatal(1,"Failed to get BFM");
	endfunction : build_phase

	pure virtual function operation_t get_op(input bit destroy);
	pure virtual function bit [31:0] get_data();
	
	task run_phase(uvm_phase phase);
		automatic queue_elem_t elem;
		phase.raise_objection(this);

		bfm.reset_alu();

        repeat (100000) begin : tester_main

            elem.destroy_op        = $urandom() % 2; 
            elem.destroy_crc       = $urandom() % 2;
            elem.destroy_operand   = $urandom() % 2; 
            elem.destroy_byte_count= $urandom() % 2;
	        
            elem.op_set = get_op(elem.destroy_op);
            elem.A      = get_data();
            elem.B      = get_data();  
            
            bfm.enqueue_element(elem);

        end

		phase.drop_objection(this);

	endtask : run_phase


endclass : base_tester
