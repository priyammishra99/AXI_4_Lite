`timescale 1ns/1ps

module axi_top_tb;

parameter ADDRESS    = 32;
parameter DATA_WIDTH = 32;

logic ACLK;
logic ARESETN;
logic START_WRITE;
logic START_READ;
logic [ADDRESS-1:0] address;
logic [DATA_WIDTH-1:0] DATA;


axi4_top dut(
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    .START_WRITE(START_WRITE),
    .START_READ(START_READ),
    .address(address),
    .DATA(DATA)
);



initial begin
    ACLK = 0;
    forever #5 ACLK = ~ACLK;
end



initial begin
    ARESETN = 0;
    START_WRITE = 0;
    START_READ  = 0;
    address = 0;
    DATA = 0;

    repeat(5) @(posedge ACLK);

    ARESETN = 1;
end



// Monitor all AXI Handshakes


always @(posedge ACLK)
begin

    if(dut.master.M_AWVALID && dut.slave.S_AWREADY)
        $display("[%0t] AW HANDSHAKE  Address = %h",
                  $time,dut.master.M_AWADDR);

    if(dut.master.M_WVALID && dut.slave.S_WREADY)
        $display("[%0t] W HANDSHAKE   Data = %h",
                  $time,dut.master.M_WDATA);

    if(dut.master.M_BREADY && dut.slave.S_BVALID)
        $display("[%0t] B HANDSHAKE   BRESP = %0d",
                  $time,dut.slave.S_BRESP);

    if(dut.master.M_ARVALID && dut.slave.S_ARREADY)
        $display("[%0t] AR HANDSHAKE  Address = %h",
                  $time,dut.master.M_ARADDR);

    if(dut.master.M_RREADY && dut.slave.S_RVALID)
        $display("[%0t] R HANDSHAKE   Data = %h",
                  $time,dut.slave.S_RDATA);

end



// WRITE TASK


task automatic axi_write
(
input [31:0] addr,
input [31:0] data
);

begin

    @(posedge ACLK);

    address = addr;
    DATA    = data;

    START_WRITE = 1;

    // Hold request for two clocks
    repeat(2) @(posedge ACLK);

    START_WRITE = 0;

    // Wait until write response completes
    wait(dut.master.state_w == dut.master.WRITE_RESPONSE);

    @(posedge ACLK);

    wait(dut.master.state_w == dut.master.IDLE_W);

    @(posedge ACLK);

    $display("--------------------------------------");
    $display("WRITE COMPLETE");
    $display("ADDR  = %h",addr);
    $display("DATA  = %h",data);

    $display("Slave Register[%0d] = %h",
             addr[6:2],
             dut.slave.register[addr[6:2]]);

    if(dut.slave.register[addr[6:2]]==data)
        $display("WRITE PASS");
    else
        $display("WRITE FAIL");

    $display("--------------------------------------");

end

endtask



// READ TASK


task automatic axi_read
(
input [31:0] addr,
input [31:0] expected
);

begin

    @(posedge ACLK);

    address = addr;

    START_READ = 1;

    repeat(2) @(posedge ACLK);

    START_READ = 0;

    wait(dut.master.state_r == dut.master.READ_DATA);

    @(posedge ACLK);

    wait(dut.master.state_r == dut.master.IDLE_R);

    @(posedge ACLK);

    $display("--------------------------------------");
    $display("READ COMPLETE");
    $display("ADDR = %h",addr);

    $display("Expected = %h",expected);
    $display("Read     = %h",dut.master.read_data);

    if(dut.master.read_data==expected)
        $display("READ PASS");
    else
        $display("READ FAIL");

    $display("--------------------------------------");

end

endtask




// Test Sequence


initial
begin

    @(posedge ARESETN);

    repeat(3) @(posedge ACLK);

    
    // Test 1
    

    axi_write(32'h00000008,32'hDEADBEEF);

    axi_read(32'h00000008,32'hDEADBEEF);


    // Test 2
   

    axi_write(32'h00000010,32'h12345678);

    axi_read(32'h00000010,32'h12345678);


    // Test 3
    

    axi_write(32'h00000014,32'hCAFEBABE);

    axi_read(32'h00000014,32'hCAFEBABE);



    #50;

    $display("======================================");
    $display("SIMULATION FINISHED");
    $display("======================================");

    $finish;

end

endmodule