`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2016 01:52:58 PM
// Design Name: 
// Module Name: multiplyAccumulator
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


module multiplyAccumulator
#(
  parameter nData = 16,
  parameter datBW = 16
)
(
  input   [nData * datBW - 1 : 0]   inA,
  input   [nData * datBW - 1 : 0]   inB,
  input                             clk,
  input                             rst,
//  input                             execute,
  output      [2 * datBW - 1 : 0]   mac_out,
  output                            mac_done
  
);

  reg [$clog2(nData) - 1 : 0] cursor = 0;
  
  
// I have a feeling that this could be done with more elegant code
//  mac_done will be reset to 0 when cursor is reset. 
  reg almost_done = 0;
  assign mac_done = (cursor==0) && almost_done;

//  Do I want to have two copies of result register?  
  reg [2 * datBW - 1 : 0] result = 0;
  
  assign mac_out = mac_done ? result : 0;

  
  always @(posedge clk) begin
    if (rst) begin
      cursor  <=  0;
      result  <=  {(nData * datBW - 1){1'b0}};
      almost_done <= 0;
    end else if (~mac_done) begin
//    end else if (~mac_done && execute) begin
      result <= result + inA[cursor * datBW  +: datBW] * inB[cursor * datBW +: datBW];
      cursor <= cursor + 1;
    end 
    
    if  (cursor == (nData-1)) begin
      almost_done <= 1;
    end
  end

endmodule
