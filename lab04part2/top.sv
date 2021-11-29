`timescale 1ns/1ps

module top();
    import alu_pkg::*;
    
    alu_bfm bfm();
    mtm_Alu u_mtm_Alu (
        .clk  (bfm.clk),
        .rst_n(bfm.rst_n), 
        .sin  (bfm.sin),
        .sout (bfm.sout)
    );
  
    testbench testbench_h;

    initial begin
        testbench_h = new(bfm);
        testbench_h.execute();
    end 
endmodule