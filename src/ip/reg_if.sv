interface reg_if;
    logic [31:0] reg_addr;
    logic [31:0] reg_rdata;
    logic [31:0] reg_wdata;
    logic reg_write;
    logic reg_read;
    
    modport master(
        input reg_rdata,
        output reg_addr,
        output reg_wdata,
        output reg_write,
        output reg_read
    );
    
    modport slave(
        output reg_rdata,
        input reg_addr,
        input reg_wdata,
        input reg_write,
        input reg_read
    );
endinterface