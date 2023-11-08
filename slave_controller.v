`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Master Controller
// Module Name: master_controller
// Project Name: 
// Description: This is slave-cum-controller which gives out the ready to master
//              when it receives valid from the peripheral controller after 
//              sending the 32 bits wide pwdata and 32 bits wide paddr to fifo.
//              
//                   
// 
//////////////////////////////////////////////////////////////////////////////////


module slave_apb #(parameter ID=1)(
  input              clk,
  input [1:0]        psel,
  input              penable,
  input              pwrite,
  input              pready_cont,
  output             pready,
  input [31:0]       pwdata,
  input [31:0]       paddr,
  output             valid,
  output [31:0]      fifo_data
);
  reg [3:0]  p_state = 0;
  reg        r_pready = 0;
  reg        r_valid = 0;
  reg [31:0] r_fifo_data = 0;
  parameter  IDLE = 2'd0;
  parameter  SETUP = 2'd1;
  parameter  REG_PWDATA = 2'd2;
  parameter  CHECK_READY = 2'd3;
  parameter  MAKE_READY_LOW = 3'd4;
  
 // reg [31:0]     mem [31:0];
  integer i;
  
//  initial begin
//    for(i = 0; i < 32 ; i = i + 1) begin
//      mem[i] = i*10;
//    end
//  end
  always @(posedge clk) begin
    case (p_state) 
      IDLE: begin
        if (psel == ID & penable) begin
          p_state <= SETUP;
        end else begin
          p_state <= IDLE;
        end
        r_valid <= 1'b0;
      end
      SETUP: begin
        if (penable == 1) begin
            r_fifo_data <= paddr;
            p_state <= REG_PWDATA;
            r_valid <= 1'b1;
        end else begin
            p_state <= SETUP;
        end     
      end
      
      REG_PWDATA : begin
        r_fifo_data <= pwdata;
        p_state <= CHECK_READY;
      end 
      
      CHECK_READY : begin
        if (pready_cont) begin
          r_pready <= 1'b1;
          p_state <= MAKE_READY_LOW;
        end 
          r_valid <= 1'b0;     
      end
      MAKE_READY_LOW : begin
        r_pready <= 1'b0;
        p_state <= IDLE;
      end 
    endcase
  end

  assign pready = r_pready;
  assign valid = r_valid;
  assign fifo_data = r_fifo_data;
  
  
endmodule

