`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Master Controller
// Module Name: master_controller
// Project Name: 
// Description: This is the slave peripheral controller which controls the reading
//              of the data from the fifo and converts the 32 bits wide paddr and
//              pwdata into 8 bits. And this is then sent to the transmitter.
//              
//                   
// 
//////////////////////////////////////////////////////////////////////////////////



module slave_peripheral_controller(
  input         clk,
  output        valid_rd_en,
  input [31:0]  fifo_data_in,
  input         empty_flag,
  input         full_flag,
  output [7:0]  cont_data_out,      
  input         trans_done,
  output        tx_valid,
  output        ready_slv
);
  reg [7:0]     r_cont_data_out = 0;
  reg           r_valid_rd_en = 0;
  reg [2:0]     p_state = 0;
  reg           r_tx_valid = 0;
  reg           r_ready_slv = 0;
  parameter     IDLE = 3'd0;
  parameter     MAKE_RD_EN_0 = 3'd1;
  parameter     REG_ADDR_STATE1 = 3'd2;
  parameter     REG_ADDR_STATE2 = 3'd3;
//  parameter     ADDR_STATE1_MAKE_RD_EN_0 = 3'd;
  parameter     CHECK_EMPTY_FLAG = 3'd4;
  parameter     MAKE_RD_EN_0_DATA = 3'd5;
  parameter     REG_DATA_STATE1 = 3'd6; 
  parameter     REG_DATA_STATE2 = 3'd7;

  reg [2:0]     r_data_index = 3'd4;
  reg [2:0]     r_addr_index = 3'd4;
  

always @(posedge clk) begin
  case (p_state)
    IDLE : begin
      r_ready_slv <= 1'b0;
      if (!empty_flag) begin
        p_state <= MAKE_RD_EN_0;
        r_valid_rd_en <= 1'b1;    
      end
    end
    
    MAKE_RD_EN_0 : begin
      r_valid_rd_en <= 1'b0;
      p_state <= REG_ADDR_STATE1;
    end
    
    REG_ADDR_STATE1 : begin
      r_tx_valid <= 1'b1;
      r_cont_data_out <= fifo_data_in[(r_addr_index * 8) - 1 -: 8];
      p_state <= REG_ADDR_STATE2;
    end    
       
    REG_ADDR_STATE2 : begin
      if (trans_done == 1) begin 
        if (r_addr_index > 1) begin
          p_state <= REG_ADDR_STATE1;
          r_addr_index <= r_addr_index - 1;
        end else begin 
          r_addr_index <= 3'd4;
          p_state <= CHECK_EMPTY_FLAG;
        end
      end else begin
        r_tx_valid <= 1'b0;
      end
    end
    CHECK_EMPTY_FLAG : begin
      if (!empty_flag) begin
        p_state <= MAKE_RD_EN_0_DATA;
        r_valid_rd_en <= 1'b1;
      end
    end
    
    MAKE_RD_EN_0_DATA : begin
      r_valid_rd_en <= 1'b0;
      p_state <= REG_DATA_STATE1;
    end
    
    REG_DATA_STATE1 : begin
      r_tx_valid <= 1'b1;
      r_cont_data_out <= fifo_data_in[(r_data_index * 8) - 1 -: 8];
      p_state <= REG_DATA_STATE2; 
    end
    
    REG_DATA_STATE2 : begin
      if (trans_done == 1) begin 
        if (r_data_index > 1) begin
          p_state <= REG_DATA_STATE1;
          r_data_index <= r_data_index - 1;
        end else begin 
          r_data_index <= 3'd4;
          p_state <= IDLE;
          r_ready_slv <= 1'b1;
        end
      end else begin
        r_tx_valid <= 1'b0;
      end
    end  
  endcase
end
assign tx_valid = r_tx_valid;
assign valid_rd_en = r_valid_rd_en;
assign cont_data_out = r_cont_data_out;
assign ready_slv = r_ready_slv;
 
endmodule
