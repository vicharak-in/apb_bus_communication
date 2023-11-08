`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Asynchronous FIFO
// Module Name: fifo
// Description:  
// 


//////////////////////////////////////////////////////////////////////////////////


module fifo #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 8,
  // shifting the binary number 1 to the left by ADDR_WIDTH positions
  parameter RAM_DEPTH = 1 << ADDR_WIDTH)(
                   
  input         wr_clk,              
  //Frequency at which the data is being written to the fifo
  input         rd_clk,              
  //Frequency at which the data is being read from the fifo
  input         we,                  
  //Whenever the valid from the preceding module is asserted the data is being written
  input         re,                  
  //Whenever the valid from the succeeding module is asserted the data is being read
  input [DATA_WIDTH-1:0]   data_in,  
  //The data that's written
  output [DATA_WIDTH-1:0]  data_out, 
  //The data that's read
  output        full_flag,           
  //Full flag is asserted when all locations of the FIFO is full
  output        empty_flag,          
  //Empty flag is asserted when the fifo is empty
  output [ADDR_WIDTH-1:0] occupants  
  //Gives the no. of elements/data in the FIFO 
);
  reg [DATA_WIDTH-1:0]  mem [RAM_DEPTH-1:0];
  reg [ADDR_WIDTH-1:0]        rptr = 0;  //[$clog2(DEPTH)-1:0] 
  //Points to the data that's being read
  reg [ADDR_WIDTH-1:0]        wptr = 0;  
  //Points to the data that's being written
  reg [DATA_WIDTH-1:0]        r_data_out = 0; 
  integer i;

  initial begin
    for (i = 0; i < RAM_DEPTH; i = i + 1) begin
        mem[i] = 0;
    end
  end

// Writing the incoming data in the memory when the write enable is high 
  always @(posedge wr_clk) begin
    if (we & !full_flag) begin
      mem[wptr] <= data_in;
      wptr <= wptr + 1;
    end  
  end 
// Reading the first written data from the memory when the read enable is high  
  always @(posedge rd_clk) begin
    if (re & !empty_flag) begin
      r_data_out <= mem[rptr];
      rptr <= rptr + 1;
    end  
  end
// Full flag is raised when the read pointer is one position ahead of the write pointer     
  assign full_flag = (rptr-1 == wptr);
// Empty flag is raised when the read and pointer are at the same location
  assign empty_flag = (wptr == rptr);
  assign occupants = wptr - rptr;
  assign data_out = r_data_out;   
endmodule