`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2023 12:36:56 PM
// Design Name: 
// Module Name: LED
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


module LED(
    input [3:0] state, //made the state 4 bits. Could always make it more or less.
    input data_ready,
    output [3:0] state_LEDs,
    output data_LED
    );
    
    assign LED = state;
    assign data_LED = data_ready;
    
    
endmodule
