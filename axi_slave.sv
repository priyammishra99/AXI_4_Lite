`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2026 18:50:47
// Design Name: 
// Module Name: axi_slave
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


module axi_slave #(
    parameter ADDRESS = 32,
    parameter DATA_WIDTH = 32
    )
    (
        //Global Signals
        input                           ACLK,
        input                           ARESETN,

        ////Read Address Channel INPUTS
        input           [ADDRESS-1:0]   S_ARADDR,
        input                           S_ARVALID,
        //Read Data Channel INPUTS
        input                           S_RREADY,
                       
        //Write Address Channel INPUTS
        /* verilator lint_off UNUSED */
        input           [ADDRESS-1:0]   S_AWADDR,
        input                           S_AWVALID,
        //Write Data  Channel INPUTS
        input          [DATA_WIDTH-1:0] S_WDATA,
        input          [3:0]            S_WSTRB,
        input                           S_WVALID,
        //Write Response Channel INPUTS
        input                           S_BREADY,	

        //Read Address Channel OUTPUTS
        output logic                    S_ARREADY,
        //Read Data Channel OUTPUTS
        output logic    [DATA_WIDTH-1:0]S_RDATA,
        output logic         [1:0]      S_RRESP,
        output logic                    S_RVALID,
        //Write Address Channel OUTPUTS
        output logic                    S_AWREADY,
        output logic                    S_WREADY,
        
        //Write Response Channel OUTPUTS
        output logic         [1:0]      S_BRESP,
        output logic                    S_BVALID
    );

    localparam no_of_registers = 32;

    logic [DATA_WIDTH-1 : 0] register [no_of_registers-1 : 0];
    logic [4 : 0]    addr;
    
   typedef enum logic [1:0] {IDLE_R , R_ADDR , R_DATA } type_state_r;
   type_state_r state_r , next_state_r;
   
   typedef enum logic [1:0] {IDLE_W , W_ADDR , W_DATA , W_RESP } type_state_w;
   type_state_w state_w , next_state_w;
   
   always_ff@(posedge ACLK) begin
   if(!ARESETN) 
   state_r <= IDLE_R;
   else 
   state_r <= next_state_r;
   end
   
   always_ff@(posedge ACLK)begin
   if(!ARESETN)
   state_w <= IDLE_W;
   else
   state_w <= next_state_w;
   end
   
   logic[4:0] awaddr;
   always_ff @(posedge ACLK) begin
    if (!ARESETN)
        awaddr <= 0;
    else if (S_AWVALID && S_AWREADY)
        awaddr <= S_AWADDR[6:2];
end

   integer i;
   
   always_ff@(posedge ACLK)begin
   if(!ARESETN)begin
   for (i = 0; i < 32; i++) begin
                register[i] <= 32'b0;
       end  
       end       
       else
      if (S_WREADY && S_WVALID) begin
      
      
   if (S_WSTRB[0])
            register[awaddr][7:0] <= S_WDATA[7:0];

        if (S_WSTRB[1])
            register[awaddr][15:8] <= S_WDATA[15:8];

        if (S_WSTRB[2])
            register[awaddr][23:16] <= S_WDATA[23:16];

        if (S_WSTRB[3])
            register[awaddr][31:24] <= S_WDATA[31:24];
            end
      end
      
      always_ff@(posedge ACLK)begin
       if(!ARESETN) 
       addr <= 5'd0;
       else
       if(S_ARVALID && S_ARREADY)
       addr <= S_ARADDR[6:2];
       end
      
   
   always_comb begin
   case(state_r)
   
   IDLE_R : begin
   
    S_ARREADY = 0;
    S_RDATA = 32'd0;
    S_RRESP = 2'd0;
    S_RVALID = 0;
    if(S_ARVALID)
    next_state_r = R_ADDR;
    else 
    next_state_r = IDLE_R;
    end
    
    R_ADDR :  begin
    S_ARREADY = 1;
    S_RDATA = 32'd0;
    S_RRESP = 2'd0;
    S_RVALID = 0;
    if(S_ARVALID && S_ARREADY)
    next_state_r = R_DATA;
    else
    next_state_r = R_ADDR;
    end
    
   R_DATA : begin
   S_ARREADY = 0;
    S_RDATA = register[addr];
    S_RRESP = 2'd0;
    S_RVALID = 1;
    if(S_RREADY && S_RVALID)
    next_state_r = IDLE_R;
    else
    next_state_r = R_DATA;
    end
    
    endcase
    end
   
   always_comb begin
   case(state_w)
   
   IDLE_W : begin
   S_AWREADY = 0;
   S_WREADY = 0;
   S_BRESP = 2'd0;
   S_BVALID = 0;
   if(S_AWVALID)
   next_state_w = W_ADDR;
   else
   next_state_w = IDLE_W;
   end
   
   W_ADDR : begin
   S_AWREADY = 1;
   S_WREADY = 0;
   S_BRESP = 2'd0;
   S_BVALID = 0;
   if(S_AWREADY && S_AWVALID)
   next_state_w = W_DATA;
   else
   next_state_w = W_ADDR;
   end
   
   W_DATA : begin
   S_AWREADY = 0;
   S_WREADY = 1;
   S_BRESP = 2'd0;
   S_BVALID = 0;
   if(S_WREADY && S_WVALID )
   next_state_w = W_RESP ;
   else
   next_state_w = W_DATA;
   end
   
   W_RESP : begin
    S_AWREADY = 0;
   S_WREADY = 0;
   S_BRESP = 2'd0;
   S_BVALID = 1;
   if(S_BVALID && S_BREADY)
   next_state_w = IDLE_W;
   else
   next_state_w = W_RESP;
   end
   
   endcase
   end
endmodule
