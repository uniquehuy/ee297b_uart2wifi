module uart2wifi_core_sram(
    input clk,
    input rst,
    reg_if.slave sram_reg_if
);

    reg [31:0] network_name_reg, network_name_reg_d;
    reg [31:0] network_pass_reg, network_pass_reg_d;
    reg [31:0] other, other_d;
    
    wire [31:0] addr, wdata;
    wire write, read;
    reg [31:0] rdata;

    assign addr = sram_reg_if.reg_addr;
    assign wdata = sram_reg_if.reg_wdata;
    assign sram_reg_if.reg_rdata = rdata;
    assign write = sram_reg_if.reg_write;
    assign read = sram_reg_if.reg_read;
    
    always @(posedge clk) begin
        if (rst) begin
            network_name_reg = 0;
            network_pass_reg = 0;
            other = 0;
        end
        else begin
            network_name_reg <= network_name_reg_d;
            network_pass_reg <= network_pass_reg_d;
            other <= other_d;
        end
    end
    
    
    always_comb begin
        if (write) begin
            case (addr)
            0: network_name_reg_d = wdata;
            1: network_pass_reg_d = wdata;
            2: other_d = wdata;
            endcase
        end
    end
    
    always_comb begin
        if (read) begin
            case (addr)
            0: rdata = network_name_reg;
            1: rdata = network_pass_reg;
            2: rdata = other;
            endcase
        end
    end
endmodule
