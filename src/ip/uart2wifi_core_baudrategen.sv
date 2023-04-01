`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2023 9:46:54 PM
// Design Name: 
// Module Name: uart2wifi_core_baudrategen
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


module uart2wifi_core_baudrategen(
    input wire clk,
    input wire rst,
    input wire enable,
    output wire baudtick
    );
    
    parameter numticks = 162;
    
    reg [15:0] count;
    wire [15:0] next;
    
    always @ (posedge clk, posedge rst)
        begin
            if(rst)
                count <= 0;
            else
                count <= next;
    end
    
    // current baud rate =  50 MHz/(163*16) = approx 19200 bps
    assign next = (((count == numticks)||(!enable)) ? 0 : count+1'b1);
    
    assign baudtick = (((count == numticks)) ? 1'b1 : 1'b0);
                
endmodule
