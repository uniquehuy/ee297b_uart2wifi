`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2023 05:33:43 PM
// Design Name: 
// Module Name: uart2wifi_core_uart
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


module uart2wifi_core_uart(
    input wire clk,
    input wire rst,
    input wire rx,
    input wire tx_fifo_wr,
    input wire rx_fifo_rd,
    input wire [7:0] write_data,
    output wire tx,
    output wire [7:0] read_data
    );
    
  
  
  wire [7:0] uart_wdata;  
  wire [7:0] uart_rdata;
  
  //Signals from TX/RX to FIFOs
  wire uart_wr;
  wire uart_rd;
  
  //wires between FIFO and TX/RX
  wire [7:0] tx_data;
  wire [7:0] rx_data;
  wire [7:0] status;
  
  //FIFO Status
  wire tx_full;
  wire tx_empty;
  wire rx_full;
  wire rx_empty;
  
  //UART status ticks
  wire tx_done;
  wire rx_done;
  
  //baud rate signal
  wire baudtick;
  
  assign status = {6'b000000,tx_full,rx_empty};
  
  // initial assignment for rd, will need to change for future
  //assign uart_rd = rx_fifo_rd;
  
  // for loopback test
  assign uart_rd =!rx_empty ; 
  
  assign uart_wr = tx_fifo_wr;
  assign uart_wdata = write_data; 
  
  assign read_data = uart_rdata;
  
  uart2wifi_core_baudrategen uart2wifi_core_baudrategen_inst(
    .clk(clk),
    .rst(rst),
    .baudtick(baudtick)
  ); 
   /*
  uart2wifi_core_fifo  
   #(.DWIDTH(8))
	uart2wifi_core_fifo_inst_tx (
    .clk(clk),
    .rst(rst),
    .rd(tx_done),
    .wr(uart_wr),
    .write_data(uart_wdata[7:0]),
    .empty(tx_empty),
    .full(tx_full),
    .read_data(tx_data[7:0])
  ); 
  */
  uart2wifi_core_fifo  
   #(.DWIDTH(8))
	uart2wifi_core_fifo_inst_rx (
    .clk(clk),
    .rst(rst),
    .rd(uart_rd),
    .wr(rx_done),
    .write_data(rx_data[7:0]),
    .empty(rx_empty),
    .full(rx_full),
    .read_data(uart_rdata[7:0])
  );
  
  uart2wifi_core_uart_rx uart2wifi_core_rx_inst(
    .clk(clk),
    .rst(rst),
    .b_tick(baudtick),
    .rx(rx),
    .rx_done(rx_done),
    .dout(rx_data[7:0])
  );
  
  // loopback tx
  uart2wifi_core_uart_tx uart2wifi_core_tx_inst(
    .clk(clk),
    .rst(rst),
    .tx_start(!rx_empty),
    .b_tick(baudtick),
    .d_in(uart_rdata[7:0]),
    .tx_done(tx_done),
    .tx(tx)
  );
  
  
  /*
  //UART transmitter
  uart2wifi_core_uart_tx uart2wifi_core_tx_inst(
    .clk(clk),
    .rst(rst),
    .tx_start(!tx_empty),
    .b_tick(baudtick),
    .d_in(tx_data[7:0]),
    .tx_done(tx_done),
    .tx(tx)
  );*/
endmodule

 
 
  

