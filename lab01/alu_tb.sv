`timescale 1ns/1ps
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

 History:
 2021-10-05 RSz, AGH UST - test modified to send all the data on negedge clk
 and check the data on the correct clock edge (covergroup on posedge
 and scoreboard on negedge). Scoreboard and coverage removed.
 2021-10-26 Jakub Maternowski, AGH UST - test modified to be used with more comlex alu (serial input and output).
 */

`define DATA_TRANSFER   1'b0
`define CTL_TRANSFER    1'b1

function [3:0] generate_crc4(input [67:0] d);
    
    logic [3:0] c;
    logic [3:0] newcrc;
    begin
	    c =  4'b0000;
        newcrc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
        newcrc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
        newcrc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
        newcrc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
    end
    return newcrc;
endfunction :generate_crc4
   
   
function [2:0] generate_crc3(input [36:0] d);

     logic [2:0] c;
     logic [2:0] newcrc;
     begin
	   c = 3'b000;
       newcrc[0] = d[35] ^ d[32] ^ d[31] ^ d[30] ^ d[28] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[11] ^ d[10] ^ d[9] ^ d[7] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[1];
       newcrc[1] = d[36] ^ d[35] ^ d[33] ^ d[30] ^ d[29] ^ d[28] ^ d[26] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[16] ^ d[15] ^ d[14] ^ d[12] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[2] ^ d[1] ^ d[0] ^ c[1] ^ c[2];
       newcrc[2] = d[36] ^ d[34] ^ d[31] ^ d[30] ^ d[29] ^ d[27] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[17] ^ d[16] ^ d[15] ^ d[13] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[3] ^ d[2] ^ d[1] ^ c[0] ^ c[2];
     end
     return newcrc;
endfunction :generate_crc3



module alu_tb();
    
    //------------------------------------------------------------------------------
    // type and variable definitions
    //------------------------------------------------------------------------------
    
    typedef enum bit[2:0] {
        and_op                   = 3'b000,
        or_op                    = 3'b001,
        add_op                   = 3'b100,
        sub_op                   = 3'b101
    } operation_t;
    
    enum bit [3:0] {
        NULL_flag                = 4'b0000,
        N_flag                   = 4'b0001,
        Z_flag                   = 4'b0010,
        O_flag                   = 4'b0100,
        C_flag                   = 4'b1000
    } flag;
    
    bit                sin;
    wire               sout;
    bit                clk;
    bit                rst_n;
    bit signed         [31:0]  A;
    bit signed         [31:0]  B;
	
	// test specification elements
    bit destroy_crc;
    bit destroy_op;
    bit destroy_byte_count;
    bit destroy_operand;
    reg err;
    reg signed [31:0] C;
    reg [3:0] flags;
    reg [2:0] crc;
    reg [5:0] err_flags;
    reg parity;
    wire [2:0] op;
    
    operation_t        op_set;
    assign op = op_set;
    
    string             test_res = "PASSED";

    //------------------------------------------------------------------------------
    // DUT instantiation
    //------------------------------------------------------------------------------
	mtm_Alu u_mtm_Alu (
		.clk  (clk),
		.rst_n(rst_n), 
		.sin  (sin), 
		.sout (sout) );
	
    //------------------------------------------------------------------------------
    // Clock generator
    //------------------------------------------------------------------------------
    initial begin : clk_gen
        clk = 0;
        forever begin : clk_frv
            #10;
            clk = ~clk;
        end
    end
    
    //---------------------------
    // ALU low level send/receive functions
    //---------------------------
    
    
    task tx_byte(input bit t, input bit [7:0] data);
        integer i;
        begin
            @(negedge clk) sin = 1'b0;
            @(negedge clk) sin = t;
            for (i = 0; i < 8; i = i + 1) 
                @(negedge clk) sin = data[7-i];
            @(negedge clk) sin = 1'b1;           
        end
    endtask
    
    task rx_byte(output bit [7:0] data, output bit t);
        integer i;
        begin
            wait (sout === 1'b0);
            @(negedge clk);
            @(negedge clk) t = sout;
            for (i = 0; i < 8; i = i + 1) 
                @(negedge clk) data[7-i] = sout;
            wait (sout === 1'b1);
        end
    endtask
    
    //---------------------------
    // ALU  send/receive helper functions
    //---------------------------
    
    
    task tx_operand(input bit [31:0] operand, input bit destroy_byte_count);
        integer i;
        begin
            for (i = 0; i < (destroy_byte_count ? $urandom_range(3, 0) : 4); i = i + 1)
                tx_byte(`DATA_TRANSFER, operand[31-8*i-:8]);
        end
    endtask
    
    task ALU_send_ctl(input operation_t operation, input bit [3:0] crc);
        integer i;
        begin
            tx_byte(`CTL_TRANSFER, {1'b0, operation, crc});
        end
    endtask
    
    //---------------------------
    // ALU main send/receive functions
    //---------------------------
        
    
    task ALU_tx(input bit [31:0] A, input bit [31:0] B, input operation_t operation, input bit destroy_crc, input bit destroy_operand, input bit destroy_byte_count);
        integer i;
        bit [31:0] A_temp;
        bit [3:0] crc, crc_temp;
        begin
            i = $urandom() % 32;
            A_temp = A;
            A_temp[i] = ~A_temp[i];
            
            tx_operand(destroy_operand ? A_temp : A, destroy_byte_count);
            tx_operand(B, destroy_byte_count);
            
            crc_temp = generate_crc4({A, B, 1'b1, operation});
	        crc = destroy_crc ? crc_temp^4'b0001 : crc_temp; //exemplary bit inversion
            ALU_send_ctl(operation, crc);
        end
    endtask
    

     task ALU_rx(output bit err, output bit signed [31:0] C, output bit [3:0] flags, output bit [2:0] crc, output bit [5:0] err_flags, bit parity);
        integer i;   
        bit [7:0] received_data[5];
        bit [4:0] frame_types;
        begin
            rx_byte(received_data[0], frame_types[0]);          
            case (frame_types[0])
                `DATA_TRANSFER: begin
                    for (i = 1; i < 5; i = i + 1)   
                        rx_byte(received_data[i], frame_types[i]);
                    C = {received_data[0], received_data[1], received_data[2], received_data[3]};
                    {flags, crc} = received_data[4][6:0];
                    err = 1'b0;
                end
                `CTL_TRANSFER: begin  
                    {err_flags, parity} = received_data[0][6:0];
                    err = 1'b1;
                end
                default: assert(0 == 1);
            endcase
        end
    endtask
    
        
    //------------------------------------------------------------------------------
    // Tester
    //------------------------------------------------------------------------------
    
    //------------------------
    // Random data generation 
    
    function operation_t get_op(input bit destroy);
        bit [2:0] op_choice;
        op_choice = destroy ? $urandom_range(7,4) : $urandom_range(3,0);
        case (op_choice)
            0 : return and_op;
            1 : return or_op;
            2 : return add_op;
            3 : return sub_op;
            4 : return operation_t'(3'b010);
            5 : return operation_t'(3'b011);
            6 : return operation_t'(3'b110);
            7 : return operation_t'(3'b111);
        endcase 
    endfunction
    
    //---------------------------------
    function bit [31:0] get_data();
        bit [1:0] zero_ones;
        zero_ones = 2'($random);
        if (zero_ones == 2'b00)
            return 32'h00000000;
        else if (zero_ones == 2'b11)
            return 32'hFFFFFFFF;
        else
            return 32'($random);
    endfunction : get_data
    
    //------------------------
    // Tester main
    
    task check_errors();
        begin
            automatic bit signed   [31:0] expected       = get_expected_result(A, B, op_set);
            automatic bit unsigned [ 3:0] expected_flags = get_expected_flags(A, B, op_set);
            automatic bit unsigned [ 2:0] expected_crc   = generate_crc3({expected, 1'b0, expected_flags});
            
            automatic bit crc_mismatch  = (err === 1'b0) && (crc !== expected_crc);
            automatic bit flag_error    = (err === 1'b0) && (flags !== expected_flags);
            automatic bit value_error   = (err === 1'b0) && (C !== expected);
            automatic bit data_error    = (err === 1'b1) && err_flags[2] && err_flags[5];
            automatic bit crc_error     = (err === 1'b1) && err_flags[1] && err_flags[4];
            automatic bit op_error      = (err === 1'b1) && err_flags[0] && err_flags[3];
            automatic bit parity_error  = (err === 1'b1) && (^{1'b1, err_flags, parity} === 1'b1);
            
            automatic bit [6:0] errors = {crc_mismatch, flag_error, value_error, data_error, crc_error, op_error, parity_error};
            automatic bit [6:0] errors_expected = {
                destroy_operand,                           
                destroy_operand,                         
                destroy_operand,                          
                destroy_byte_count,                        
                destroy_crc || destroy_operand,       
                destroy_op,                                   
                1'b0                                        
            };   
            
            // Handle errors not specified in documentation
            automatic bit unknown_error = (err === 1'b1) && ~(data_error || crc_error || op_error || parity_error);

            // mask expected errors
            errors = errors & (~errors_expected);

            assert (!errors && !unknown_error) begin
                `ifdef DEBUG
                    $display("Test passed for A=%0d B=%0d op_set=%0d", A, B, op);
                `endif
                end
            else begin
                $display("Test FAILED");
                $display("\tInput Data: A=%0d B=%0d op_set=%0d", A, B, op);
                if (unknown_error) $display("\tUnknown error");
                test_res = "FAILED";
            end
        end        
    endtask
    
    initial begin : tester
        reset_alu();
        repeat (10000) begin : tester_main
            @(negedge clk);
            destroy_op              = $urandom() % 2; 
            destroy_crc             = $urandom() % 2;
            destroy_operand   = $urandom() % 2; 
            destroy_byte_count = $urandom() % 2;
            
            op_set = get_op(destroy_op);
            A      = get_data();
            B      = get_data();  
            
            ALU_tx(A, B, op_set, destroy_crc, destroy_operand, destroy_byte_count);
            ALU_rx(err, C, flags, crc, err_flags, parity);    
            check_errors();
        end
        $finish;
    end : tester

    
    //------------------------------------------------------------------------------
    // reset task
    //------------------------------------------------------------------------------
    task reset_alu();
        `ifdef DEBUG
        $display("%0t DEBUG: alu reset performed", $time);
        `endif
        rst_n = 1'b0;
        sin = 1'b1;
        @(negedge clk);
        rst_n = 1'b1;
    endtask
    
    //------------------------------------------------------------------------------
    // calculate expected result
    //------------------------------------------------------------------------------
    function automatic logic [3:0] get_expected_flags(
            bit signed [31:0] A,
            bit signed [31:0] B,
            operation_t op_set,
            reg [3:0] flags = NULL_flag
        );
        bit signed [31:0] C;
        bit [32:0] carry_check;
        case(op_set)
            and_op : C = A & B;
            or_op :  C = A | B;
            add_op : begin
                C = A + B;
                carry_check = {1'b0, A} + {1'b0, B}; 
                if (A[31] == 1'b0 && B[31] == 1'b0 && C[31] == 1'b1) flags = flags | O_flag;
                else if (A[31] == 1'b1 && B[31] == 1'b1 && C[31] == 1'b0) flags = flags | O_flag;
            end
            sub_op : begin
                C = A - B;
                carry_check = {1'b0, A} - {1'b0, B}; 
                if (A[31] == 1'b0 && B[31] == 1'b1 && C[31] == 1'b1) flags = flags | O_flag;
                else if (A[31] == 1'b1 && B[31] == 1'b0 && C[31] == 1'b0) flags = flags | O_flag;            
            end 
            default: C = -1;
        endcase
           
        if (carry_check[32] == 1'b1) flags = flags | C_flag;
        if (C < 0) flags = flags | N_flag;
        if (C == 0) flags = flags | Z_flag;

        return flags;
    endfunction
    
    function automatic logic signed [31:0] get_expected_result(
            bit signed [31:0] A,
            bit signed [31:0] B,
            operation_t op_set
        );
        bit signed [31:0] C;
        case(op_set)
            and_op : C = A & B;
            or_op :  C = A | B;
            add_op : C = A + B;
            sub_op : C = A - B;
            default: C = -1;
        endcase
        
        return C;
    endfunction
    
    final begin 
        $display("Test %s.",test_res);
    end
	
endmodule



