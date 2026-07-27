`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 17:10:54
// Design Name: 
// Module Name: axi_top
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


module axi4_top#(
parameter ADDRESS = 32,
parameter  DATA_WIDTH = 32
)
(

input logic ACLK,
input logic  ARESETN,
input logic START_WRITE,
input logic START_READ,
input logic [ADDRESS-1:0] address,
input logic [DATA_WIDTH-1:0] DATA


    );
    
    logic M_ARVALID , M_RREADY , M_AWVALID , M_WVALID , M_BREADY ;
    logic  S_ARREADY , S_RVALID ,  S_AWREADY ,  S_WREADY ,      S_BVALID ;
    logic [1:0]  S_RRESP , S_BRESP ;
    logic [3:0] M_WSTRB ;
    logic [ ADDRESS-1:0]  M_AWADDR, M_ARADDR ;
    logic [DATA_WIDTH-1:0] M_WDATA , S_RDATA;
    
  axi_master  master(
  .ACLK(ACLK) ,
  .ARESETN(ARESETN),
  .address(address),
  .W_data(DATA),
  .START_WRITE(START_WRITE),
  .START_READ(START_READ),
  .M_RDATA(S_RDATA),
  .M_RRESP(S_RRESP),
  .M_BRESP(S_BRESP),
  .M_RVALID(S_RVALID),
  .M_AWREADY(S_AWREADY),
  .M_WREADY(S_WREADY),
  .M_BVALID(S_BVALID),
  .M_ARREADY(S_ARREADY),
  
  .M_AWADDR(M_AWADDR),
    .M_AWVALID(M_AWVALID),
    .M_WDATA(M_WDATA),
    .M_WSTRB(M_WSTRB),
    .M_WVALID(M_WVALID),
    .M_BREADY(M_BREADY),
    .M_ARADDR(M_ARADDR),
    .M_ARVALID(M_ARVALID),
    .M_RREADY(M_RREADY)
  
  );
  
  axi_slave slave(
  .ACLK(ACLK),
  .ARESETN(ARESETN),
  .S_ARADDR( M_ARADDR),
  .S_ARVALID(M_ARVALID),
  . S_RREADY(M_RREADY),
  .S_AWADDR(M_AWADDR),
  .S_AWVALID(M_AWVALID),
  .S_WDATA(M_WDATA),
  .S_WSTRB(M_WSTRB),
  .S_WVALID(M_WVALID),
  .S_BREADY(M_BREADY),
  
  .S_AWREADY(S_AWREADY),
    .S_WREADY(S_WREADY),
    .S_BRESP(S_BRESP),
    .S_BVALID(S_BVALID),
    .S_ARREADY(S_ARREADY),
    .S_RDATA(S_RDATA),
    .S_RRESP(S_RRESP),
    .S_RVALID(S_RVALID)
  );
endmodule
