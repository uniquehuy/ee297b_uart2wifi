`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2023 05:33:43 PM
// Design Name: 
// Module Name: uart2wifi_core_led
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

module uart2wifi_core_led(
    input clk,
    input led_en,
    input fsm_state state,
    output led_out, 
    output reg [3:0] led_arr
    );
    fsm_state cur_state;
    assign cur_state = state;
    assign led_out = led_en;
    
    always_comb
	begin
		case(cur_state)
			IDLE:        led_arr = 8'h1;
			SEND_DATA:   led_arr = 8'h2;
			READ_DATA:   led_arr = 8'h4;
			BUSY:        led_arr = 8'h8;
			default :    led_arr = 8'hf;
		endcase
    end
    
endmodule
