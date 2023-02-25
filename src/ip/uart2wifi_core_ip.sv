`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Huy Nguyen
// 
// Create Date: 02/20/2023 05:02:52 PM
// Design Name: 
// Module Name: uart2wifi_core_ip
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
module uart2wifi_core_ip(
    input clk,
    input rst,
    input switch_in,
    output board_led0,
    output [3:0] state_led,
    input data_in_test,
    input data_out_test
    );
    
    wire led_en;
    fsm_state cur_state;
    
    // Communication with register file
    reg_if fsm_reg_if();
    
    // Instantialize modules
    uart2wifi_core_fsm uart2wifi_core_fsm_inst(.clk(clk), .rst(rst), .switch_in(switch_in), .led_en(led_en), .data_in(data_in_test), 
                                                .data_out(data_out_test), .fsm_reg_if(fsm_reg_if), .state_to_led(cur_state));
    uart2wifi_core_led uart2wifi_core_led_inst(.clk(clk), .led_en(led_en),.state(cur_state),.led_arr(state_led) ,.led_out(board_led0));
    uart2wifi_core_serial uart2wifi_core_serial_inst();
    uart2wifi_core_uart uart2wifi_core_uart_inst();
    uart2wifi_core_sram uart2wifi_core_sram_inst (.clk(clk), .rst(rst), .sram_reg_if(fsm_reg_if));
endmodule
