`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2026 00:56:08
// Design Name: 
// Module Name: axi_master
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


module axi_master #(
   parameter ADDRESS = 32,
   parameter DATA_WIDTH = 32
   )(
   //Global Signals
        input                           ACLK,
        input                           ARESETN,

        input                           START_READ,
        input                           START_WRITE,

        input          [ADDRESS-1 : 0]  address,
        input          [DATA_WIDTH-1:0]  W_data,

        //Read Address Channel INPUTS
        input                           M_ARREADY,
        //Read Data Channel INPUTS
        
        input          [DATA_WIDTH-1:0] M_RDATA,
        input               [1:0]       M_RRESP,
        input                           M_RVALID,
        //Write Address Channel INPUTS
        input                           M_AWREADY,
        //
        input                           M_WREADY,
        //Write Response Channel INPUTS
        input             [1:0]         M_BRESP,
        input                           M_BVALID,
        //Read Address Channel OUTPUTS
        output logic    [ADDRESS-1 : 0] M_ARADDR,
        output logic                    M_ARVALID,
        //Read Data Channel OUTPUTS
        output logic                    M_RREADY,
        //Write Address Channel OUTPUTS
        output logic    [ADDRESS-1 : 0] M_AWADDR,
        output logic                    M_AWVALID,
        //Write Data  Channel OUTPUTS
        output logic   [DATA_WIDTH-1:0] M_WDATA,
        output logic   [3:0]            M_WSTRB,
        output logic                    M_WVALID,
        //Write Response Channel OUTPUTS
        output logic                    M_BREADY	
   
    );
    
  
   
    
    typedef enum logic [1:0] { IDLE_R , R_ADDR , READ_DATA } state_type_r;
    state_type_r state_r , next_state_r;
    
    typedef enum logic [1:0] { IDLE_W , WRITE_ADDR , WRITE_DATA , WRITE_RESPONSE } state_type_w;
    state_type_w state_w , next_state_w; 
    
    always_ff@(posedge ACLK) begin
    if(!ARESETN)
    state_r <= IDLE_R;
    else
    state_r <= next_state_r;
    end
    
    always_ff@(posedge ACLK) begin
    if(!ARESETN)
    state_w <= IDLE_W;
    else 
    state_w <= next_state_w;
    end
    
    
    
    logic [DATA_WIDTH-1:0] read_data;
    always_ff @(posedge ACLK) begin
    if(!ARESETN)
        read_data <= '0;
    else if(M_RVALID && M_RREADY && M_RRESP == 2'b00)
        read_data <= M_RDATA;
end


    
    always_comb begin
    case(state_r)
    IDLE_R : begin
    M_ARADDR = 32'd0;
    M_ARVALID = 0;
    M_RREADY = 0;
 
   
    
    if(START_READ)begin
    next_state_r = R_ADDR ;
    end
    else
    next_state_r = IDLE_R;
    end
  
   
    
    R_ADDR : begin
    M_ARADDR = address;
    M_ARVALID = 1;
    M_RREADY =0 ;
  
    
    if(M_ARVALID && M_ARREADY)
    next_state_r = READ_DATA;
    else next_state_r = R_ADDR;
    end
    
    READ_DATA : begin
    
    M_ARADDR = 32'd0 ;
    M_ARVALID = 0;
    M_RREADY = 1;

    if(M_RREADY && M_RVALID)begin
    
    next_state_r = IDLE_R;
    end
    else next_state_r = READ_DATA ;
    end
   
    
      endcase
      end
      
      always_comb begin
      case(state_w)
      
      IDLE_W : begin
      M_AWADDR = 32'd0;
      M_AWVALID = 0;
      M_WDATA = 32'd0;
      M_WSTRB = 4'd0;
      M_WVALID = 0;
      M_BREADY = 0;
      if(START_WRITE)
      next_state_w = WRITE_ADDR;
      else
      next_state_w = IDLE_W;
      end
      
      
      
      WRITE_ADDR : begin
      M_AWADDR = address;
      M_AWVALID = 1;
      M_WDATA = 32'd0;
      M_WSTRB = 4'd0;
      M_WVALID = 0;
      M_BREADY = 0;
      if(M_AWVALID && M_AWREADY)
      next_state_w = WRITE_DATA ;
      else next_state_w = WRITE_ADDR;
     end
      
      WRITE_DATA :  begin
       M_AWADDR = 32'd0;
      M_AWVALID = 0;
      M_WDATA = W_data;
      M_WSTRB = 4'b1111;
      M_WVALID = 1 ;
      M_BREADY = 0;
      if(M_WREADY && M_WVALID)
      next_state_w = WRITE_RESPONSE;
      else next_state_w = WRITE_DATA ;
      end
      
      WRITE_RESPONSE : begin
     M_AWADDR = 32'd0;
      M_AWVALID = 0;
      M_WDATA = 32'd0;
      M_WSTRB = 4'd0;
      M_WVALID = 0 ;
      M_BREADY = 1;
      if(M_BVALID && M_BREADY && M_BRESP == 2'b00)
      next_state_w = IDLE_W;
      else next_state_w = WRITE_RESPONSE ;
      end
      endcase
       
        end
        endmodule
      
      
      
      
      
    
      
      
      

