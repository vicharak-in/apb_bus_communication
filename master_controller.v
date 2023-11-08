`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Master Controller
// Module Name: master_controller
// Project Name: 
// Description: This module controls the reading of the data from the fifo and sends 
//              psel- 1 byte, pwrite- 1 byte, paddr- 4 bytes and pwdata- 4 bytes to the
//              master and so it controls the input data that goes to the master.  
// 
//////////////////////////////////////////////////////////////////////////////////


module master_controller(
  output          rd_en,
  input           empty_flag,
  input           full_flag, 
  input [7:0]     fifo_data,
  output          p_write,
  output [1:0]    p_sel,
  output [31:0]   p_addr,
  output [31:0]   p_wdata,
  input           rd_clk,
  output          o_valid,
  input           slv_pready
);
  reg             r_rd_en = 0;
  reg [31:0]      r_pwdata = 0;  
  reg [1:0]       r_psel = 0;
  reg             r_pwrite = 0;
  reg [31:0]      r_paddr = 0;  
  reg [4:0]       p_state = 0;
  reg [2:0]       r_index_addr = 3'd4;
  reg [2:0]       r_index_wdata = 3'd4;
  reg             r_o_valid = 0;
  
  parameter IDLE = 4'd0;
  parameter IDLE_MAKE_RDEN_0 = 4'd1;
  parameter REG_SEL = 4'd2;
  parameter REG_SEL_MAKE_RDEN_0 = 4'd3;
  parameter REG_WRITE = 4'd4;
  parameter REG_WRITE_MAKE_RDEN_0 = 4'd5;
  parameter REG_ADDR_STATE1 = 4'd6; 
  parameter REG_ADDR_STATE1_MAKE_RDEN_0 = 4'd7; 
  parameter REG_ADDR_STATE2 = 4'd8;
  parameter REG_ADDR_STATE2_MAKE_RDEN_0 = 4'd9;
  parameter REG_WDATA_STATE1 = 4'd10;
  parameter REG_WDATA_STATE1_MAKE_RDEN_0 = 4'd11;
  parameter REG_WDATA_STATE2 = 4'd12;
  parameter CHECK_READY = 4'd13;
  

  always @(posedge rd_clk) begin
    case (p_state)
//      IDLE : begin
//        if (empty_flag) begin
//          p_state <= IDLE;
//        end else begin
//          p_state <= REG_WAIT;
//        end 
//      end
      IDLE : begin
        if (!empty_flag) begin
          r_rd_en <= 1;
          p_state <= IDLE_MAKE_RDEN_0;          
        end
        r_o_valid <= 1'b0;
      end  
      
      IDLE_MAKE_RDEN_0 : begin
          r_rd_en <= 0;
          p_state <= REG_SEL;
      end
      
      REG_SEL : begin
        r_psel <= fifo_data[1:0];
        if (!empty_flag) begin
          r_rd_en <= 1;
          p_state <= REG_SEL_MAKE_RDEN_0;
        end
      end
      
      REG_SEL_MAKE_RDEN_0 : begin
          r_rd_en <= 0;
          p_state <= REG_WRITE;
      end
      
      REG_WRITE : begin
        r_pwrite <= fifo_data[0];
        if (!empty_flag) begin
          r_rd_en <= 1;
          p_state <= REG_WRITE_MAKE_RDEN_0;
        end
      end
      
      REG_WRITE_MAKE_RDEN_0 : begin
          r_rd_en <= 0;
          p_state <= REG_ADDR_STATE1;
      end
      
      REG_ADDR_STATE1 : begin  
        r_paddr [(r_index_addr*8) - 1 -: 8] <= fifo_data;
        if(!empty_flag) begin
          r_rd_en <= 1;
          p_state <= REG_ADDR_STATE1_MAKE_RDEN_0;
        end
      end
      
      REG_ADDR_STATE1_MAKE_RDEN_0 : begin
          r_rd_en <= 0;
          p_state <= REG_ADDR_STATE2;
      end
      
      REG_ADDR_STATE2 : begin
        if ( r_index_addr > 1)begin
          r_index_addr <= r_index_addr - 1;            
          p_state <= REG_ADDR_STATE1;
        end else begin
          r_index_addr <= 4;
          p_state <= REG_WDATA_STATE1;
        end
      end
      
 /*     REG_ADDR_STATE2_MAKE_RDEN_0 : begin
          r_rd_en <= 0;
          p_state <= REG_WDATA_STATE1;
      end */
      
      REG_WDATA_STATE1 : begin
        r_pwdata [(r_index_wdata*8) - 1 -: 8] <= fifo_data;
        if (!empty_flag) begin
          r_rd_en <= 1; 
          p_state <= REG_WDATA_STATE1_MAKE_RDEN_0;
        end 
        else if (r_index_wdata == 1) begin
          r_index_wdata <= 4;
          r_o_valid <= 1'b1;
//          p_state <= CHECK_READY;
          p_state <= IDLE;
//          r_pwdata [(r_index_wdata*8) - 1 -: 8] <= fifo_data; 
        end      
      end  
      
      REG_WDATA_STATE1_MAKE_RDEN_0 : begin
          r_rd_en <= 0;
          p_state <= REG_WDATA_STATE2;
      end
      
      REG_WDATA_STATE2 : begin 
        if (r_index_wdata > 1)begin
          r_index_wdata <= r_index_wdata - 1;            
          p_state <= REG_WDATA_STATE1;
        end else begin
          r_index_wdata <= 4;
//        p_state <= CHECK_READY;
          p_state <= IDLE;
          r_o_valid <= 1'b1;
        end
      end
/*     CHECK_READY : begin
        if (slv_pready) begin
          p_state <= IDLE;
        end
      end   */
    endcase
  end 
  assign  p_sel = r_psel;
  assign  p_write = r_pwrite;
  assign  p_addr = r_paddr;
  assign  p_wdata = r_pwdata;
  assign  o_valid = r_o_valid;
  assign  rd_en = r_rd_en;
endmodule

