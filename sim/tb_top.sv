`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2023 05:38:55 PM
// Design Name: 
// Module Name: tb_top
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
`define LOOPBACK

module tb_top();
    logic clk, rst;
    
    // switch
    logic switch_one;
    
    // led output
    logic board_led0;
    
    // tb inputs
    logic data_in_test;
    logic data_out_test;
    logic error_flag = 0;
    
    logic [31:0] counter, counter_d;
    
    //tb outputs
    logic baud_tick;
    
    // fifo tb I/Os
    logic fifo_rd, fifo_wr; 
    logic empty, full;
    logic [7:0] write_data, read_data;
    
    // uart tb I/Os
    logic rx, tx, tx_wr;
    logic enable;
    logic [7:0] first_data;
    logic [7:0] second_data;
    logic [7:0] uart_write_data;
    logic [7:0] latched_dout;
    
    reg_if reg_if_inst();
    
    // IP (TOP LEVEL)
    //uart2wifi_core_ip dut(.clk(clk), .rst(rst), .switch_in(switch_one), .board_led0(board_led0), .data_in_test(data_in_test), .data_out_test(data_out_test));
    
    // Standalone modules
    //uart2wifi_core_sram reg_dut(.clk(clk), .rst(rst), .sram_reg_if(reg_if_inst));
    //uart2wifi_core_baudrategen baud_dut(.clk(clk), .rst(rst), .baudtick(baud_tick));
    //uart2wifi_core_fifo fifo_dut(.clk(clk), .rst(rst), .rd(fifo_rd), .wr(fifo_wr), .empty(empty), 
    // .full(full), .write_data(write_data), .read_data(read_data));
    
    uart2wifi_core_uart uart_dut(.clk(clk), .rst(rst), .tx_wr(tx_wr), .write_data(uart_write_data), .rx(rx), .tx(tx), .latched_dout(latched_dout));
     
     
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
        end
        else
            counter <= counter_d;
    end
    
    always_comb begin
        counter_d = counter + 1;
    end
    
    // Set interface initial values
    initial begin
        reg_if_inst.reg_addr = 0;
        reg_if_inst.reg_wdata = 0;
        reg_if_inst.reg_write = 0;
        reg_if_inst.reg_read = 0;
    end
    
    // Set tb inputs initial board_led0
    initial begin
        data_in_test = 0;
        data_out_test = 0;
    end
            
    // Set reset and clock
    initial begin
        rst = 0;
        clk = 0;
        forever #10 clk = ~clk; //50MHz clock
    end
    
    // Kill simulation if timeout
    initial begin
        forever begin
            @(posedge clk);
            if (counter > 100000) begin
                $display("FAIL, TEST TIMEOUT");
                $finish();
            end
        end
    end
    
    // Assert reset at beginning of test
    initial begin
        #1;
        rst = 1;
        #1;
        rst = 0;
    end  
    
    // Baudgen enable initial 
    // Need to do this at time 0 becuase if this is X it causes the baudgen to malfunction 
    initial begin
       enable = 0;
    end
    
    // UART data line is held high until used
    initial begin
       rx = 1;
    end
    
    
    // MAIN TEST
    initial begin
        //test_fsm();
        //test_registers();
        //test_baud_generator();
        //test_fifo();
        test_uart();
        
        if (!error_flag) begin
            $display("=================");
            $display("   TEST PASSED   ");
            $display("=================");
        end
        else begin
            $display("=================");
            $display("   TEST FAILED   ");
            $display("=================");
        end    
        $finish();
    end
    
    
    task test_fsm();
        string tag = "test_fsm";
        $display("Starting %0s", tag);
        
        @(negedge clk);
        $display("data_in_test asserted");
        data_in_test = 1;
        data_out_test = 0;
        repeat(4)
            @(posedge clk);
        data_out_test = 1;
        data_in_test = 0;
        repeat(5)
            @(posedge clk);
        data_in_test = 0;
        data_out_test = 0;
        repeat(10)
            @(posedge clk);
        /*
        // This test is for board bringup
        switch_one = 0;
        #50;
        switch_one = 1;
        #50;
        switch_one = 0;
        #50;
        switch_one = 1;
        #50;
        switch_one = 1;
        #50;
        switch_one = 0;
        #50;
        switch_one = 1;
        #200;
        */
    endtask
    
    task test_registers();
        string tag = "test_registers";
        int random_val;
        
        $display("Starting %0s", tag);
        // Test each register
        repeat(2) begin
            for (int addr = 0; addr < 3; addr++) begin
                // Test write and readback
                random_val = $urandom();
                @(negedge clk);
                $display("Writing data: %0h to addr: %0h", random_val, addr);
                reg_if_inst.reg_addr = addr;
                reg_if_inst.reg_wdata = random_val;
                reg_if_inst.reg_write = 1;
                reg_if_inst.reg_read = 0;
                // wait for write transaction
                @(posedge clk);
                $display("Reading data at addr: %0h", addr);
                reg_if_inst.reg_addr = addr;
                reg_if_inst.reg_wdata = 0;
                reg_if_inst.reg_write = 0;
                reg_if_inst.reg_read = 1;
                
                // wait for read transaction
                @(posedge clk);
                if (reg_if_inst.reg_rdata == random_val)
                    $display("PASS, values matched at addr: %0h, received: %0h", addr, random_val);
                else begin
                    $display("FAIL, values do not match at addr: %0h, expected %0h, received %0h", addr, random_val, reg_if_inst.reg_rdata);
                    error_flag = 1;
                end
            end
        end
        $display("Finished %0s", tag);
    endtask

    task test_baud_generator();
        string tag = "test_baud_generator";
        $display("Starting %0s", tag);
        $display("Testing two ticks...");
        enable = 1'b1;
        @(posedge baud_tick);
        counter = 0;
        @(posedge baud_tick);
        if (counter == 163)
            $display("PASS, baud ticked at right time");
        else begin
            $display("FAIL, baud ticked at incorrect time, expected: %0h, received: %0h", 32'd163, counter);
            error_flag = 1;
        end
        $display("Finished %0s", tag);
    endtask

    task test_fifo();
        string tag = "test_fifo";
        $display("Starting %0s", tag);
        $display("Testing write");
        //repeat(1)
            //@(posedge clk);
        fifo_wr = 1;
        fifo_rd = 0;
        write_data = 8'h4;
        @(posedge clk);
        
        repeat(20) begin
            @(posedge clk);
            write_data = write_data+1;
            
        end  
        fifo_wr = 0;
        fifo_rd = 1;
        @(posedge clk);
        repeat (7) begin
            @(posedge clk);
        end
        fifo_wr = 1;
        fifo_rd = 1;
        repeat(8) begin
            @(posedge clk);
            write_data = write_data+1;
            
        end     
            $display(" %0h", read_data);
        $display("Finished %0s", tag);
    endtask
        
    task test_uart();
        string tag = "test_uart";
        bit [7:0] rx_data_test;
        
        rx_data_test = 8'h77;
        
        $display("Starting %0s", tag);
        $display($sformatf("Testing RX, value expected:h%h", rx_data_test));
        tx_wr = 0;
        uart_write_data = 8'h0;
        for (int j = 0; j<2;j++) begin
        // start bit
        rx = 0;
            for (int i = 0; i < 8; i++) begin
                #52083;
                rx = rx_data_test[i];
            end
        
        #52083;
        rx = 1;
        #52083;
        end
        // Check through waveforms if data_out is appropiate.
        
        /* 
        rx = 1;
        @(posedge clk); //for checking when the data is read, check the count_reg value in the rx inst
        rx = 0;
        #52083;  // current baud rate is 19200 bits/s meaning one bit is sampled about every 52083 ns
        rx = 1; // 2 one data bits
        #52083;
        #52083;
        rx = 0; // 3 zero data bits
        #52083;
        #52083;
        #52083;
        rx = 1; // 1 one data bit
        #52083;
        rx = 0; // 3 zero data bits (expeceted value 0x23)
        #52083;
        #52083;
        #52083;
        */
        // 000100011
        
        /*
        
        $display("Testing TX");
        
      
        #52083;
        tx_wr = 1;
        first_data = 8'h86;
        uart_write_data = first_data;
        
        @(posedge clk);
        second_data = 8'hFA;
        uart_write_data = second_data;
        @(posedge clk);
        tx_wr = 0;
        
        #26041; //half baud rate to sample in the middle
        $display("TX start bit, expected: %0h, received: %0h", 1'b0, tx);
        for(int i=0; i<8; i+=1)begin
            #52083;
            $display("TX data bit %0d expected: %0h, received: %0h", i, first_data[i], tx);
        end
        #52083; //one stop bit
        $display("TX stop bit expected: %0h, received: %0h", 1'b1, tx);
        $display("end first data");
        #52083;
        $display("start second data");
        $display("TX start bit expected: %0h, received: %0h", 1'b0, tx);
        for(int i=0; i<8; i+=1)begin
            #52083;
            $display("TX data bit %0d expected: %0h, received: %0h", i, second_data[i], tx);
        end
        #52083; //one stop bit
        $display("TX stop bit expected: %0h, received: %0h", 1'b1, tx);
        
        */
        #(52083*50);
        $display("Finished %0s", tag);
    endtask
    
    
endmodule
