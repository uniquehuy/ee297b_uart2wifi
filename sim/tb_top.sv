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
    logic clk, rst;
    
    // switch
    logic switch_one;
    
    // led output
    logic board_led0;
    
    uart2wifi_core_ip dut(.clk(clk), .rst(rst), .switch_in(switch_one), .board_led0(board_led0));
    
    
    initial begin
        rst = 0;
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    initial begin
        #1;
        rst = 1;
        #1;
        rst = 0;
    end
       
    initial begin
        switch_one = 0;
        #50;
        switch_one = 1;
        #50;
        switch_one = 0;
        #50;
        switch_one = 1;
        #50;
        switch_one = 1;
        #50;
        switch_one = 0;
        #50;
        switch_one = 1;
        #200;
        $finish();
    end
    
endmodule
