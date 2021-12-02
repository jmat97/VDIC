package alu_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
    //------------------------------------------------------------------------------
    // type and variable definitions
    //------------------------------------------------------------------------------

    typedef enum bit[2:0] {
        and_op                   = 3'b000,
        or_op                    = 3'b001,
        add_op                   = 3'b100,
        sub_op                   = 3'b101,
        inv_op1                  = 3'b010,
        inv_op2                  = 3'b011,
        inv_op3                  = 3'b110,
        inv_op4                  = 3'b111
    } operation_t;
    
    enum bit [3:0] {
        NULL_flag                = 4'b0000,
        N_flag                   = 4'b0001,
        Z_flag                   = 4'b0010,
        O_flag                   = 4'b0100,
        C_flag                   = 4'b1000
    } flag;
    
    typedef struct {
        bit [31:0]  A;
        bit [31:0]  B;
        bit destroy_op;
	    bit destroy_crc;
        bit destroy_byte_count;
        bit destroy_operand;
        bit err;
        bit signed [31:0] C;
        bit [3:0] flags;
        bit [2:0] crc;
        bit [5:0] err_flags;
        bit parity;
        operation_t op_set;
    } queue_elem_t;
        
    typedef enum bit {DATA = 1'b0, CTL = 1'b1} transfer_type_t; 
  
    `include "coverage.svh"
    `include "base_tester.svh"
    `include "scoreboard.svh"
    `include "env.svh" 
    `include "random_tester.svh"
    `include "random_test.svh"
    `include "extremum_tester.svh"
    `include "extremum_test.svh"

    
endpackage : alu_pkg