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
        
    reg_if reg_if_inst();
    
    // IP (TOP LEVEL)
    uart2wifi_core_ip dut(.clk(clk), .rst(rst), .switch_in(switch_one), .board_led0(board_led0), .data_in_test(data_in_test), .data_out_test(data_out_test));
    
    // Standalone modules
    uart2wifi_core_sram reg_dut(.clk(clk), .rst(rst), .sram_reg_if(reg_if_inst));
    uart2wifi_core_baudrategen baud_dut(.clk(clk), .rst(rst), .baudtick(baud_tick));
    
    
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
        forever #10 clk = ~clk;
    end
    
    // Kill simulation if timeout
    initial begin
        forever begin
            @(posedge clk);
            if (counter > 10000) begin
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
    
    
    // MAIN TEST
    initial begin
        test_fsm();
        test_registers();
        test_baud_generator();
        
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
        @(posedge baud_tick);
        counter = 0;
        @(posedge baud_tick);
        if (counter == 10 + 1)
            $display("PASS, baud ticked at right time");
        else begin
            $display("FAIL, baud ticked at incorrect time, expected: %0h, received: %0h", 32'd10, counter);
            error_flag = 1;
        end
        $display("Finished %0s", tag);
    endtask

endmodule
