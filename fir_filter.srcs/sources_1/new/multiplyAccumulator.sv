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
  output reg [2 * datBW - 1 : 0]    result = 0,
  output                            mac_done
  
);
  reg [nData * datBW - 1 : 0] localInA;
  reg [nData * datBW - 1 : 0] localInB;
  reg [$clog2(nData) - 1 : 0] cursor = 0;
  reg written = 0;
  assign mac_done = (cursor == (nData-1));
  

  
  always @(posedge clk) begin
    if (rst) begin
      cursor  <=  0;
      written <=  0;
      result  <=  {(nData * datBW - 1){1'b0}};
      $display("Reset registered.");
      
    end else if (~mac_done) begin
      result <= result + inA[cursor * datBW  +: datBW] * inB[cursor * datBW +: datBW];
      cursor <= cursor + 1;            

      $display("result possibly previous result... = %d", result);                     
    end
  end

endmodule
