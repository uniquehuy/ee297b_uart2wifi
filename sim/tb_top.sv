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
    
    reg_if reg_if_inst();
    
    uart2wifi_core_ip dut(.clk(clk), .rst(rst), .switch_in(switch_one), .board_led0(board_led0));
    uart2wifi_core_sram reg_dut(.clk(clk), .rst(rst), .sram_reg_if(reg_if_inst));
    
    // Set interface initial values
    initial begin
        reg_if_inst.reg_addr = 0;
        reg_if_inst.reg_wdata = 0;
        reg_if_inst.reg_write = 0;
        reg_if_inst.reg_read = 0;
    end
        
    // Set reset and clock
    initial begin
        rst = 0;
        clk = 0;
        forever #10 clk = ~clk;
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
        $finish();
    end
    
    
    task test_fsm();
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
    endtask
    
    task test_registers();
        int random_val;
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
                $display("Reading data at addr: %0h", random_val, addr);
                reg_if_inst.reg_addr = addr;
                reg_if_inst.reg_wdata = 0;
                reg_if_inst.reg_write = 0;
                reg_if_inst.reg_read = 1;
                
                // wait for read transaction
                @(posedge clk);
                $display("===================");
                $display("  Checking Values  ");
                $display("===================");
                if (reg_if_inst.reg_rdata == random_val)
                    $display("PASS, values matched at addr: %0h, received: %0h", addr, random_val);
                else
                    $display("FAIL, values do not match at addr: %0h, expected %0h, received %0h", addr, random_val, reg_if_inst.reg_rdata);
            end
        end
    endtask   
endmodule
