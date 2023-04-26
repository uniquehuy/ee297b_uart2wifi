`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2023 10:27:08 PM
// Design Name: 
// Module Name: uart2wifi_core_fifo
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
/*
module slow_clk (
    input clk_in
    output clk_out
);
    reg [31:0] count = 0;
    reg clk_out;
    always @(posedge clk_in) begin
        count <= count + 1;

        if (count == 100000000) begin
            count <= 0;
            clk_out <= ~clk_out;
        end
    end 
endmodule

module d_ff(
    input clk_in,
    input D,
    output Q
);
always @(posedge clk) 
begin
 Q <= D; 
end 
endmodule 




module uart2wifi_core_button
(
    input clk,
    input button_in,
    output out
    output out_led
);

wire clk_out_slow, q1, q2;
slow_clk slow_clk_inst(.clk_in(clk), .clk_out(clk_out_slow));
d_ff flop1(.clk_in(clk_out_slow), .D(button_in), .Q(q1));
d_ff flop2(.clk_in(clk_out_slow), .D(q1), .Q(q2));
out_led = 
out = q2;
endmodule
*/

module uart2wifi_core_button
(
    input clk,
    input rst,
    input button_in,
    output out,
    output out_led
);


reg flag, debounce_done_flag, debounce_done_flag_d;
reg [31:0] counter , counter_d;

assign out_led = flag;
assign out = debounce_done_flag;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        flag <= 0;
    end
    else begin
        if (button_in)
            flag <= 1;
        else if (debounce_done_flag)
            flag <= 0;
    end
end

// Counter
always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 0;
    end
    else begin
        if (flag == 1) begin
            counter <= counter_d;
        end
        else begin
            counter <= 0;
        end
    end
end

always @(posedge clk or posedge rst) begin
    if (rst)
        debounce_done_flag <= 0;
    else begin
        debounce_done_flag <= debounce_done_flag_d;
    end
end

always_comb begin
    counter_d = counter + 1;
    if (counter == 70000000) begin // 0.7s
        debounce_done_flag_d = 1;
        counter_d = 0;
    end
    else begin
        debounce_done_flag_d = 0;
    end
end
endmodule