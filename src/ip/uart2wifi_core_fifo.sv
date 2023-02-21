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


module uart2wifi_core_fifo #(parameter DWIDTH=8) 
(
    input wire clk,
    input wire rst, 
    input wire rd,
    input wire wr,
    input wire [DWIDTH-1:0] write_data,
    
    output wire empty,
    output wire full,
    output wire [DWIDTH-1:0] read_data
                
 );
 
    parameter address_size = 1;
    
    reg [DWIDTH-1:0] mem [2**address_size-1:0];
    reg wr_ptr, rd_ptr;
    reg wr_ptr_next, rd_ptr_next;
    
    reg full_reg;
    reg empty_reg;
    reg full_next;
    reg empty_next;
    
    wire w_en;
    
    always@(posedge clk)
        if(w_en)
        begin
            mem[wr_ptr] <= write_data;
        end
     
    //   
    always@(posedge clk)
        if(rd & ~empty_reg)
        begin
            read_data <= mem[rd_ptr];
        end
        
            
    
    assign w_en = wr & ~full_reg;
    assign full = full_reg;
    assign empty = empty_reg;
    //State Machine
    always@(posedge clk, negedge rst)
    begin
        if(!rst)
            begin
                full_reg <= 1'b0;
                empty_reg <= 1'b1;
                wr_ptr <= 1'b0;
                rd_ptr <= 1'b0;
            end
        else
            begin
                full_reg <= full_next;
                empty_reg <= empty_next;
                wr_ptr <= wr_ptr_next;
                rd_ptr <= rd_ptr_next;
            end
    end
    
    
   // Need to add logic for updating read and write pointer here
   
   
endmodule
