`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Master Controller
// Module Name: master_controller
// Project Name: 
// Description: This is the master design, the psel, pwrite, paddr and pwdata
//              sent by the master controller goes to the ext_psel, ext_write,
//              ext_addr, ext_wdata. Master sends these signals to the slave and
//              in turn get a ready as a response from the slave whenever the
//              slave is ready. This works only for the write transfer.   
// 
//////////////////////////////////////////////////////////////////////////////////


module apb_master_write_transfer(
  input              pclk,
  input              valid,      //valid is asserted to confirm that the master has got a valid request             
  input [1:0]        ext_psel,   //Triggering the master with the external pin for selecting slave
  input              ext_write,  //Triggering the master with the external pin to indicate read/write
  input [31:0]       ext_addr,   /*Triggering the master with the external pin to specify address from where the read 
                                   should happen*/  
  input [31:0]       ext_wdata,
  output [1:0]       psel,       
  output             penable,  
  output             pwrite,
  input              pready,     //Ready. The slave uses this signal to extend an APB transfer.
  input [31:0]       slv_prdata, //The read data from the slave 
  output [31:0]      prdata,     //Not in protocol //Master is giving out the read data received from the slave
  output [31:0]      pwdata,
  output [31:0]      paddr
);
  
  reg                r_penable=0;
  reg [31:0]         r_prdata=0;
  reg [1:0]          r_ext_psel = 0;
  reg [31:0]         r_ext_addr= 32'd0;
  reg                r_ext_write = 0;
  reg [31:0]         r_ext_wdata = 0;      
  reg [1:0]          p_state=2'd0;
  parameter          IDLE = 2'd0;
  parameter          SETUP = 2'd1;
  parameter          ACCESS = 2'd2;
  
always @(posedge pclk) begin
    case (p_state)
      IDLE : begin              //Idle state where Penable = 0 and Psel = 0
        if(!valid) begin
          r_penable <= 0;
          r_ext_psel <= 3'd0;
          p_state <= IDLE;
        end else begin
          p_state <= SETUP;
        end
      end
      
      SETUP : begin            //Setup state where penable is still 0 and Psel is selected  
        r_penable <= 0;
        r_ext_psel <= ext_psel;
        r_ext_addr <= ext_addr;
        r_ext_wdata <= ext_wdata;
        p_state <= ACCESS;
        r_ext_write <= ext_write; 
      end
      
      
      ACCESS : begin          //Access state where the transfer is enabled
        r_penable <= 1'b1;
        if (ext_write == 0) begin
          r_prdata <= slv_prdata;
        end 
        if (pready == 0) begin          
          p_state <= ACCESS;
//        end else if (valid && pready) begin
//          p_state <= SETUP;
//        end else if (!valid && pready) begin
        end else begin
          p_state <= IDLE;
          r_penable <= 0;
        end
      end
      default: p_state <= IDLE; 
    endcase
  end
        

 
 assign penable = r_penable;
 assign psel = r_ext_psel;
 assign pwrite = r_ext_write;
 assign paddr = r_ext_addr;
 assign pwdata = r_ext_wdata;
 assign prdata = r_prdata;
endmodule

