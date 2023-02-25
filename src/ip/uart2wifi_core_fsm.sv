`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2023 05:22:34 PM
// Design Name: 
// Module Name: uart2wifi_core_fsm
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
`ifndef ENV_PARAMS
`include "env_params.sv"
`endif

module uart2wifi_core_fsm(
    input clk,
    input rst,
    input switch_in,
    output led_en,
    reg_if.master fsm_reg_if
    );

fsm_state current_state, next_state;
assign led_en = current_state;

always @(posedge clk or posedge rst) begin
    if (rst)
        current_state <= IDLE;
    else begin
        current_state <= next_state;
    end
end

always_comb begin
/*
    case (current_state)
        IDLE: next_state = BUSY;
        BUSY: next_state = IDLE;
    endcase
*/

    if (switch_in) begin
        next_state = BUSY;
    end
    else begin
        next_state = IDLE;
    end

end

endmodule
