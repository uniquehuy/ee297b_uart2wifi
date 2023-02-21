`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2023 05:38:55 PM
// Design Name: 
// Module Name: tb_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_top();
    logic clk;
    uart2wifi_core_ip dut(clk);
    
    
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
       
    initial begin
        #200;
        $finish();
    end
    
endmodule
