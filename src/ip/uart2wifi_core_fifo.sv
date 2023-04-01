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
 
    parameter address_size = 4;
    
    reg [DWIDTH-1:0] mem [2**address_size-1:0];
    reg [address_size-1:0] wr_ptr, rd_ptr;
    reg [address_size-1:0] wr_ptr_next, rd_ptr_next;
    reg [address_size-1:0] wr_ptr_succ, rd_ptr_succ;
    
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
   assign read_data = mem[rd_ptr];        
            
    
    assign w_en = wr & ~full_reg;
    assign full = full_reg;
    assign empty = empty_reg;
    //State Machine
    always@(posedge clk, posedge rst)
    begin
        if(rst)
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
   always@*
   begin
    wr_ptr_succ = wr_ptr+1;
    rd_ptr_succ = rd_ptr+1;
    
    wr_ptr_next = wr_ptr;
    rd_ptr_next = rd_ptr;
    full_next = full_reg;
    empty_next = empty_reg;
    
    case({w_en,rd})
        2'b00: 
        begin
        
        end
        2'b01:
            if(~empty_reg)
                begin
                    rd_ptr_next = rd_ptr_succ;
                    full_next = 1'b0;
                    if (rd_ptr_succ == wr_ptr)
                        empty_next = 1'b1;
               end 
        2'b10:
            if(~full_reg)
                begin
                    wr_ptr_next = wr_ptr_succ;
                    empty_next = 1'b0;
                    if (wr_ptr_succ == rd_ptr)
                        full_next = 1'b1;
                end 
        2'b11:
            begin
                wr_ptr_next = wr_ptr_succ;
                rd_ptr_next = rd_ptr_succ;
            end 
     endcase
              
                    
   end
   
endmodule
