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
    input wire tx_wr,
    input wire [7:0] write_data,
    output wire tx,
    output reg [7:0] latched_dout,
    input send_buffer,
    output esp_tx,
    input esp_rx
    );
    
  
  
  wire [7:0] uart_wdata;  
  wire [7:0] uart_rdata;
  
  wire [7:0] esp_uart_rdata;
  wire [7:0] esp_uart_wdata;
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
  
  // ESP
  wire esp_rx_done;
  wire esp_tx_done;

  wire [7:0] esp_tx_data;
  wire [7:0] esp_rx_data;
  wire [7:0] esp_status;
  
  wire esp_tx_full;
  wire esp_tx_empty;
  wire esp_rx_full;
  wire esp_rx_empty;
  
    
  //baud rate signal
  wire baudtick;
  
  //wire [7:0] latched_dout;
  
  assign status = {6'b000000,tx_full,rx_empty};
  
  assign uart_wr = tx_wr;
  assign uart_wdata = write_data; 
  
  always @(negedge rx_empty) begin
    #10;
    latched_dout <= uart_rdata[7:0];
  end
  
  // ================================================
  // send rd until rx_empty
  // if get send_buffer tick, start TX
  
  reg [7:0] manual_data_slash = 8'h5C;
  reg [7:0] manual_data_n     =	8'h6E;
  reg [7:0] manual_data_r     = 8'h72;
  
  reg [7:0] manual_data_to_send [4]  = {manual_data_slash, manual_data_r, manual_data_slash, manual_data_n};
  
  reg manual_write_d, manual_write;
  reg [7:0] manual_data, manual_data_d; 
  reg [3:0] send_state, send_state_d;
  reg send_flag, send_flag_d;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
        manual_write <= 0;
        send_state <= 0;
        send_flag <= 0;
        manual_data <= 0;
    end
    else begin
        send_state <= send_state_d;
        send_flag <= send_flag_d;
        manual_write <= manual_write_d;
        manual_data <= manual_data_d;
    end
  end
  
  always_comb begin
    manual_write_d = manual_write;
    manual_data_d = manual_data;
    case (send_state)
        0: begin // IDLE
            if (!rx_empty & send_buffer) begin
                send_state_d = 2;
                send_flag_d = 1;
            end
            else begin
                send_state_d = 0;
                send_flag_d = 0;
            end
        end

        1: begin // ADD \r\n to BUFFER
            manual_data_d = manual_data_to_send[0];
            manual_write_d = 1;
            send_state_d = 3;
        end
        
        3: begin // ADD \r\n to BUFFER
            manual_data_d = manual_data_to_send[1];
            manual_write_d = 1;
            send_state_d = 4;
        end
        
        4: begin // ADD \r\n to BUFFER
            manual_data_d = manual_data_to_send[2];
            manual_write_d = 1;
            send_state_d = 5;
        end
        
        5: begin // ADD \r\n to BUFFER
            manual_data_d = manual_data_to_send[3];
            manual_write_d = 1;
            send_state_d = 2;
        end



        2: begin
            manual_write_d = 0;
            if (tx_done & !rx_empty) begin
                send_state_d = 2;
                send_flag_d = 1;
            end
            else if (tx_done & rx_empty) begin
                send_state_d = 0;
                send_flag_d = 0;
            end
            else begin // tx done not detected, waiting for it to be done
                send_flag_d = 0;
                send_state_d = 2;
            end
        end
    endcase
  end
  // ==============================================
  uart2wifi_core_baudrategen uart2wifi_core_baudrategen_inst(
    .clk(clk),
    .rst(rst),
    .baudtick(baudtick)
  ); 
   
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
 /* 
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
  */
  
  // LOOPBACK TESTING
  uart2wifi_core_fifo  
   #(.DWIDTH(8))
	uart2wifi_core_fifo_inst_rx (
    .clk(clk),
    .rst(rst),
    .rd(send_flag),
    .wr(rx_done),
    .wr_man(manual_write),
    .write_data(rx_data[7:0]),
    .empty(rx_empty),
    .full(rx_full),
    .read_data(uart_rdata[7:0]),
    .write_data_manual(manual_data)
  );

  
  uart2wifi_core_uart_rx uart2wifi_core_rx_inst(
    .clk(clk),
    .rst(rst),
    .b_tick(baudtick),
    .rx(rx),
    .rx_done(rx_done),
    .dout(rx_data[7:0])
  );
  
  //UART transmitter
  /*
  uart2wifi_core_uart_tx uart2wifi_core_tx_inst(
    .clk(clk),
    .rst(rst),
    .tx_start(!tx_empty),
    .b_tick(baudtick),
    .d_in(tx_data[7:0]),
    .tx_done(tx_done),
    .tx(tx)
  );
  */

  uart2wifi_core_uart_tx uart2wifi_core_tx_inst(
    .clk(clk),
    .rst(rst),
    .tx_start(send_flag),
    .b_tick(baudtick),
    .d_in(uart_rdata[7:0]),//.d_in(uart_rdata[7:0]),
    .tx_done(tx_done),
    .tx(esp_tx) // replace this with ESP TX
  );
  
  
  
  
  // ESP SIDE
  uart2wifi_core_fifo  
   #(.DWIDTH(8))
	esp_rx_fifo (
    .clk(clk),
    .rst(rst),
    .rd(esp_tx_done),
    .wr(esp_rx_done),
    .wr_man(manual_write),
    .write_data(esp_rx_data[7:0]),
    .empty(esp_rx_empty),
    .full(esp_rx_full),
    .read_data(esp_uart_rdata[7:0]),
    .write_data_manual(manual_data)
  );
  
  uart2wifi_core_uart_rx esp_rx_inst(
    .clk(clk),
    .rst(rst),
    .b_tick(baudtick),
    .rx(esp_rx),
    .rx_done(esp_rx_done),
    .dout(esp_rx_data[7:0])
  );
  
  uart2wifi_core_uart_tx esp_tx_inst(
    .clk(clk),
    .rst(rst),
    .tx_start(!esp_rx_empty),
    .b_tick(baudtick),
    .d_in(esp_uart_rdata[7:0]),//.d_in(uart_rdata[7:0]),
    .tx_done(esp_tx_done),
    .tx(tx)
  );
  
endmodule

 
 
  

