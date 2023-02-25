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
    input data_in,
    input data_out,
    input switch_in,
    output led_en,
    output fsm_state state_to_led,
    reg_if.master fsm_reg_if
    );
    
    fsm_state current_state, next_state;
    int counter, counter_d;
    assign led_en = current_state;
    assign state_to_led = current_state;
    
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            counter <= 0;
        end
        else begin
            current_state <= next_state;
            counter <= counter_d;
        end
    end
    
    always_comb begin
        case (current_state)
            IDLE: begin
                // If data is available, read it
                if (data_in) begin
                    next_state = READ_DATA;
                end
                else if (data_out) begin
                    next_state = SEND_DATA;
                end
            end
            READ_DATA: begin
                next_state = BUSY;
            end
            
            SEND_DATA: begin
                next_state = BUSY;
            end
            
            BUSY: begin
                if (counter != 5) begin
                    counter_d = counter + 1;
                end
                else begin
                    counter_d = 0;
                    next_state = IDLE;
                end
            end
            
        endcase
        // When programmed to board
        /*
        if (switch_in) begin
            next_state = BUSY;
        end
        else begin
            next_state = IDLE;
        end
        */
    end

endmodule
