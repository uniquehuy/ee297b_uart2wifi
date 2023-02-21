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
    input clk
    );
    
    // Instantialize interfaces
    fsm_if fsm_if_inst(clk);
    led_if led_if_inst();
    
    // Instantialize modules
    uart2wifi_core_fsm uart2wifi_core_fsm_inst();
    uart2wifi_core_led uart2wifi_core_led_inst();
    uart2wifi_core_serial uart2wifi_core_serial_inst();
    uart2wifi_core_uart uart2wifi_core_uart_inst();
endmodule
